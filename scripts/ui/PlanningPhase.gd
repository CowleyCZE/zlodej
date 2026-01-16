extends Control

# Signals
signal planning_completed(plan_data)
signal planning_cancelled

# UI References - Top Panel
@onready var top_panel = $VBoxContainer/TopPanel
@onready var status_label = $VBoxContainer/TopPanel/VBoxContainer/HeaderRow/StatusLabel
@onready var timeline_slider = $VBoxContainer/TopPanel/VBoxContainer/HeaderRow/TimelineSlider
@onready var char_buttons_container = $VBoxContainer/TopPanel/VBoxContainer/CharacterBar/CharButtons
@onready var active_char_label = $VBoxContainer/TopPanel/VBoxContainer/InfoRow/ActiveCharLabel
@onready var log_container = $VBoxContainer/TopPanel/VBoxContainer/ScrollContainer/LogVBox

# UI References - Middle Panel
@onready var map_canvas = $VBoxContainer/MiddlePanel
@onready var tile_map = $VBoxContainer/MiddlePanel/TileMap
@onready var entities_layer = $VBoxContainer/MiddlePanel/EntitiesLayer
@onready var route_lines_layer = $VBoxContainer/MiddlePanel/RouteLinesLayer
@onready var ghost_lines_layer = $VBoxContainer/MiddlePanel/GhostLinesLayer

# UI References - Bottom Panel
@onready var bottom_menu = $VBoxContainer/BottomMenu
@onready var btn_walk = $VBoxContainer/BottomMenu/HBoxContainer/BtnWalk
@onready var btn_use = $VBoxContainer/BottomMenu/HBoxContainer/BtnUse
@onready var btn_wait = $VBoxContainer/BottomMenu/HBoxContainer/BtnWait
@onready var btn_guard = $VBoxContainer/BottomMenu/HBoxContainer/BtnGuard
@onready var btn_simulate = $VBoxContainer/BottomMenu/HBoxContainer/BtnSimulate
@onready var btn_inspect = $VBoxContainer/BottomMenu/HBoxContainer/BtnInspect
@onready var btn_save = $VBoxContainer/BottomMenu/HBoxContainer/BtnSave
@onready var btn_execute = $VBoxContainer/BottomMenu/HBoxContainer/BtnExecute

# State
var current_plan: Dictionary = {} # Klíč: Jméno postavy, Hodnota: Pole akcí
var active_character: Node2D = null
var is_dragging: bool = false
var temp_path_points: PackedVector2Array = []
var simulation_running: bool = false

# Mock Data pro prototyp
var characters = []

func _ready():
	_setup_mock_scene()
	_update_ui_state()
	
	# Propojení tlačítek
	btn_execute.pressed.connect(_on_BtnExecute_pressed)
	btn_save.pressed.connect(_on_BtnSave_pressed)
	btn_wait.pressed.connect(_on_BtnWait_pressed)
	btn_inspect.pressed.connect(_on_BtnInspect_pressed)
	btn_use.pressed.connect(_on_BtnUse_pressed)
	btn_guard.pressed.connect(_on_BtnGuard_pressed)
	btn_simulate.pressed.connect(_on_BtnSimulate_pressed)
	btn_walk.pressed.connect(_on_BtnWalk_pressed)
	
	# Úvodní fade in efekt
	modulate.a = 0
	create_tween().tween_property(self, "modulate:a", 1.0, 0.5)

func _setup_mock_scene():
	# Inicializace struktury plánu
	current_plan = {
		"Honza": [],
		"Specialista": [],
		"Driver": []
	}
	
	# Vytvoření testovacích postav
	_spawn_mock_character("Honza", Color(0.2, 0.6, 1.0), Vector2(100, 100))
	_spawn_mock_character("Specialista", Color(1.0, 0.4, 0.2), Vector2(150, 100))
	
	_create_character_selection_ui()
	add_log("Fáze plánování zahájena. Cíl: Vila u Labe, Mělník")

func _create_character_selection_ui():
	for child in char_buttons_container.get_children():
		child.queue_free()
		
	for char_obj in characters:
		var btn = Button.new()
		btn.text = char_obj.name
		btn.custom_minimum_size = Vector2(100, 30)
		btn.pressed.connect(func(): _select_character(char_obj))
		char_buttons_container.add_child(btn)

func _select_character(char_obj):
	active_character = char_obj
	active_char_label.text = "Aktivní: " + char_obj.name
	add_log("Přepnuto na: " + char_obj.name)
	# Zvýraznění aktivní postavy (placeholder)
	for c in characters:
		c.modulate.a = 1.0 if c == char_obj else 0.5

func _spawn_mock_character(char_name: String, color: Color, pos: Vector2):
	var sprite = Sprite2D.new()
	var tex = PlaceholderTexture2D.new()
	tex.size = Vector2(32, 32)
	sprite.texture = tex
	sprite.modulate = color
	sprite.position = pos
	sprite.name = char_name
	
	# Štítek pro identifikaci
	var lbl = Label.new()
	lbl.text = char_name
	lbl.position = Vector2(-20, -40)
	sprite.add_child(lbl)
	
	entities_layer.add_child(sprite)
	characters.append(sprite)
	
	# Vytvoření Line2D pro trasu postavy
	var line = Line2D.new()
	line.name = "Route_" + char_name
	line.width = 4.0
	line.default_color = color
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	line.antialiased = true
	
	# Holografický efekt (pulsace)
	var tween = create_tween().set_loops()
	tween.tween_property(line, "modulate:a", 0.5, 0.8)
	tween.tween_property(line, "modulate:a", 1.0, 0.8)
	
	route_lines_layer.add_child(line)

func enter_planning(target_building_data):
	status_label.text = "Plánování: %s | Čas: 00:00" % target_building_data.get("name", "Neznámé")
	add_log("Načten půdorys pro " + target_building_data.get("name", "Neznámé"))

func _input(event):
	if simulation_running: return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_try_select_character(event.position)
			else:
				if is_dragging:
					_end_drag()
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			_show_context_menu(event.position)
	
	elif event is InputEventMouseMotion and is_dragging and active_character:
		var local_pos = map_canvas.get_local_mouse_position()
		
		# Přidání bodů trasy při pohybu
		if temp_path_points.is_empty() or local_pos.distance_to(temp_path_points[temp_path_points.size() - 1]) > 20:
			temp_path_points.append(local_pos)
			_update_ghost_trail()
	
	if event is InputEventKey and event.is_action_pressed("ui_cancel"):
		emit_signal("planning_cancelled")
		add_log("Plánování zrušeno")

func _try_select_character(_mouse_pos: Vector2):
	var local_pos = entities_layer.get_local_mouse_position()
	
	for char_obj in characters:
		if char_obj.position.distance_to(local_pos) < 30:
			active_character = char_obj
			is_dragging = true
			temp_path_points.clear()
			temp_path_points.append(active_character.position)
			
			active_char_label.text = "Aktivní: " + char_obj.name
			add_log("Vybrána postava: " + char_obj.name)
			return

func _end_drag():
	is_dragging = false
	if active_character and temp_path_points.size() > 1:
		var line = route_lines_layer.get_node_or_null("Route_" + active_character.name)
		if line == null:
			push_warning("Route line not found for: " + active_character.name)
			temp_path_points.clear()
			_clear_ghost_lines()
			return
		
		for p in temp_path_points:
			line.add_point(p)
			
		var dist = 0.0
		for i in range(1, temp_path_points.size()):
			dist += temp_path_points[i - 1].distance_to(temp_path_points[i])
			
		var duration = dist / 150.0
		var action = {
			"type": "move",
			"points": temp_path_points.duplicate(),
			"duration": duration
		}
		current_plan[active_character.name].append(action)
		add_log("Přidán pohyb pro " + active_character.name + " (%.1fs)" % duration)
		active_character.position = temp_path_points[temp_path_points.size() - 1]
		_update_timeline_max()
	
	temp_path_points.clear()
	_clear_ghost_lines()

func _update_timeline_max():
	var total_max = 0.0
	for char_name in current_plan:
		var char_time = 0.0
		for action in current_plan[char_name]:
			if action.has("duration"):
				char_time += action.duration
		total_max = max(total_max, char_time)
	
	status_label.text = "Plánování: Vila u Labe | Celkový čas: %.1fs" % total_max
	timeline_slider.max_value = max(180.0, total_max + 10.0)
	timeline_slider.value = total_max

func _update_ghost_trail():
	_clear_ghost_lines()
	var line = Line2D.new()
	line.name = "Ghost"
	line.width = 2.0
	line.default_color = Color(0.3, 0.7, 1.0, 0.6) # Neonově modrá
	line.points = temp_path_points
	
	# Animace pulsace pro ghost trail
	var tween = create_tween().set_loops()
	tween.tween_property(line, "modulate:a", 0.3, 0.5)
	tween.tween_property(line, "modulate:a", 0.7, 0.5)
	
	ghost_lines_layer.add_child(line)

func _clear_ghost_lines():
	for child in ghost_lines_layer.get_children():
		child.queue_free()

func add_log(msg: String):
	var l = Label.new()
	l.text = "> " + msg
	l.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	l.add_theme_font_size_override("font_size", 14)
	log_container.add_child(l)
	log_container.move_child(l, 0)
	
	if log_container.get_child_count() > 20:
		log_container.get_child(log_container.get_child_count() - 1).queue_free()

func _show_context_menu(screen_pos: Vector2):
	add_log("Pravé tlačítko: Akce pro objekt na " + str(screen_pos))
	# Zde by se otevíralo ContextMenu.tscn


func _update_ui_state():
	# Nastavení barev pro panely (Glassmorphism je v TSCN přes ColorRect s alfa kanálem)
	# Zde můžeme přidat dynamické stylování slideru
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.3, 0.6, 1.0, 0.8)
	sb.expand_margin_top = 2
	sb.expand_margin_bottom = 2
	timeline_slider.add_theme_stylebox_override("grabber_area", sb)
	timeline_slider.add_theme_stylebox_override("grabber_area_highlight", sb)

# --- Obsluha simulace ---

func _on_BtnSimulate_pressed():
	if simulation_running: return
	simulation_running = true
	add_log("📽️ Spouštím synchronizovanou simulaci týmu...")
	
	# Reset pozic na začátek simulace
	for char_obj in characters:
		var actions = current_plan.get(char_obj.name, [])
		if actions.size() > 0:
			var first_action = actions[0]
			if first_action.has("type") and first_action.type == "move" and first_action.has("points") and first_action.points.size() > 0:
				char_obj.position = first_action.points[0]
	
	var master_tween = create_tween()
	master_tween.set_parallel(true)
	
	var max_duration = 0.0
	
	for char_name in current_plan:
		var actions = current_plan[char_name]
		if actions.is_empty(): continue
		
		var char_obj = null
		for c in characters:
			if c.name == char_name:
				char_obj = c
				break
		
		if char_obj:
			var current_delay = 0.0
			for action in actions:
				if action.type == "move":
					var points = action.points
					for i in range(1, points.size()):
						var p = points[i]
						var dist = points[i - 1].distance_to(p)
						var time = dist / 150.0 # Rychlost pohybu
						master_tween.tween_property(char_obj, "position", p, time).set_delay(current_delay)
						current_delay += time
				elif action.type == "wait":
					current_delay += action.duration
			
			max_duration = max(max_duration, current_delay)
	
	# Animace TimelineSlideru a Statusu
	timeline_slider.value = 0
	var timer_tween = create_tween()
	timer_tween.tween_method(func(val):
		timeline_slider.value = val
		status_label.text = "Simulace: Vila u Labe | Čas: %.1fs" % val
	, 0.0, max_duration, max_duration)
	
	master_tween.chain().tween_callback(func():
		simulation_running = false
		add_log("✅ Simulace dokončena. Čas akce: %.1fs" % max_duration)
		_update_timeline_max()
	)

func _on_BtnWalk_pressed():
	# V reálné aplikaci by toto přepnulo režim kurzoru na "Chůze"
	add_log("🚶 Vybrán režim chůze")

func _on_BtnExecute_pressed():
	emit_signal("planning_completed", current_plan)
	add_log("🕶️ Provádím plán!")

func _on_BtnSave_pressed():
	var json_str = JSON.stringify(current_plan, "\t")
	var file = FileAccess.open("user://plan_save.json", FileAccess.WRITE)
	if file:
		file.store_string(json_str)
		add_log("💾 Plán uložen do user://plan_save.json")
	else:
		add_log("❌ Chyba při ukládání plánu!")

func _on_BtnWait_pressed():
	if active_character:
		var duration = 5.0
		var action = {"type": "wait", "duration": duration}
		current_plan[active_character.name].append(action)
		add_log(active_character.name + ": ⏳ Čeká %.1f sekund" % duration)
		_update_timeline_max()

func _on_BtnInspect_pressed():
	add_log("🔍 Prozkoumávám objekt... Žádné stopy alarmu nenalezeny.")

func _on_BtnUse_pressed():
	if active_character:
		add_log(active_character.name + ": 🛠️ Používá předmět")

func _on_BtnGuard_pressed():
	add_log("👮 Zobrazení tras stráží: Hlídka u vily má 15s cyklus.")
