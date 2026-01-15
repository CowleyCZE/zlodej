extends Node2D

@onready var loc_list = $UI/SidePanel/Margin/VBox/LocList
@onready var miss_list = $UI/SidePanel/Margin/VBox/MissList
@onready var btn_planning = $UI/SidePanel/Margin/VBox/Btn_StartPlanning
@onready var markers_node = $Markers
@onready var rain_particles = $RainOverlay

func _ready():
	ProgressManager.mission_unlocked.connect(func(_id): _refresh_ui())
	MapEventManager.events_updated.connect(_refresh_ui)
	WeatherManager.weather_changed.connect(_on_weather_changed)
	
	_setup_signals()
	_refresh_ui()
	_on_weather_changed(WeatherManager.current_weather)

func _setup_signals():
	# Connect Location Buttons in Sidebar
	if loc_list.has_node("CernyOrel"):
		loc_list.get_node("CernyOrel").pressed.connect(_on_location_pressed.bind("CernyOrel"))
	if loc_list.has_node("CafeVltava"):
		loc_list.get_node("CafeVltava").pressed.connect(_on_location_pressed.bind("CafeVltava"))
	if loc_list.has_node("Staveniste"):
		loc_list.get_node("Staveniste").pressed.connect(_on_location_pressed.bind("Staveniste"))
	
	# Connect Mission Buttons
	if miss_list.has_node("Tutorial"):
		miss_list.get_node("Tutorial").pressed.connect(_on_mission_marker_pressed.bind("mission_tutorial"))
	if miss_list.has_node("MelTech"):
		miss_list.get_node("MelTech").pressed.connect(_on_mission_marker_pressed.bind("mission_meltech_01"))
		
	# Start Planning
	btn_planning.pressed.connect(_on_mission_marker_pressed.bind("mission_tutorial"))

func _refresh_ui():
	print("WorldMap_2D: Refreshing UI elements...")
	
	# 1. Update Mission Visibility
	if miss_list.has_node("Tutorial"):
		miss_list.get_node("Tutorial").visible = ProgressManager.unlocked_missions.has("mission_tutorial")
	if miss_list.has_node("MelTech"):
		miss_list.get_node("MelTech").visible = ProgressManager.unlocked_missions.has("mission_meltech_01")
	
	# 2. Update Location Events Visuals
	_update_location_ui("CernyOrel", "Hospoda U Černého Orla")
	_update_location_ui("CafeVltava", "Café Vltava")
	_update_location_ui("Staveniste", "Staveniště U Dubu")
	
	# 3. Update Map Markers
	for marker in markers_node.get_children():
		var event = MapEventManager.get_event_for(marker.name)
		if not event.is_empty():
			_animate_marker(marker, event.type)
		else:
			marker.modulate = Color.WHITE

func _update_location_ui(loc_id: String, base_name: String):
	if not loc_list.has_node(loc_id): return
	
	var btn = loc_list.get_node(loc_id) as Button
	var event = MapEventManager.get_event_for(loc_id)
	
	if event.is_empty():
		btn.text = base_name
		btn.modulate = Color.WHITE
	else:
		btn.text = "[%s] %s" % [event.label, base_name]
		match event.type:
			MapEventManager.EventType.POLICE_RAID:
				btn.modulate = Color.RED
			MapEventManager.EventType.INTEL_SALE:
				btn.modulate = Color.YELLOW
			MapEventManager.EventType.MARKET_SALE:
				btn.modulate = Color.GREEN

func _animate_marker(marker: Node, type: int):
	match type:
		MapEventManager.EventType.POLICE_RAID:
			marker.modulate = Color.RED
		MapEventManager.EventType.INTEL_SALE:
			marker.modulate = Color.YELLOW
		_:
			marker.modulate = Color.CYAN

func _on_weather_changed(weather: WeatherManager.WeatherType):
	if not rain_particles: return
	
	match weather:
		WeatherManager.WeatherType.RAIN:
			rain_particles.emitting = true
			# Fog effect via modulate? Or separate node
			modulate = Color(0.8, 0.8, 1.0) # Cold blue tint
		WeatherManager.WeatherType.FOG:
			rain_particles.emitting = false
			modulate = Color(0.7, 0.7, 0.7) # Desaturated/Grey
		WeatherManager.WeatherType.CLEAR:
			rain_particles.emitting = false
			modulate = Color.WHITE

func _on_location_pressed(location_id: String):
	var location_name = location_id
	match location_id:
		"CernyOrel": location_name = "Hospoda U Černého Orla"
		"CafeVltava": location_name = "Café Vltava"
		"Staveniste": location_name = "Staveniště U Dubu"
	
	var view_packed = load("res://scenes/ui/LocationView.tscn")
	if view_packed:
		var view = view_packed.instantiate()
		$UI.add_child(view)
		view.setup(location_id, location_name)

func _on_mission_marker_pressed(mission_id: String):
	var mission_data: MissionData = null
	for m in MissionDB.missions:
		if m.mission_id == mission_id:
			mission_data = m
			break
	
	if mission_data:
		var popup_packed = load("res://scenes/ui/IntelPopup.tscn")
		if popup_packed:
			var popup = popup_packed.instantiate()
			$UI.add_child(popup)
			popup.setup(mission_data)
			popup.planning_started.connect(_start_planning)

func _start_planning(mission_data: MissionData):
	GameManager.set_current_level(mission_data.target_location)
	EventBus.planning_activated.emit(mission_data)
	GameManager.change_state(GameManager.State.PLANNING)
