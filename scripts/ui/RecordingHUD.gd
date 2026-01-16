class_name RecordingHUD
extends Control

@onready var btn_rec: Button = $ControlPanel/HBox/Btn_Rec
@onready var btn_stop: Button = $ControlPanel/HBox/Btn_Stop
@onready var btn_play: Button = $ControlPanel/HBox/Btn_Play
@onready var btn_wait: Button = $ControlPanel/HBox/Btn_Wait
@onready var btn_equip: Button = $ControlPanel/HBox/Btn_Equip
@onready var btn_next_obj: Button = $ControlPanel/HBox/Btn_NextObj
@onready var btn_prev_obj: Button = $ControlPanel/HBox/Btn_PrevObj
@onready var time_slider: HSlider = $ControlPanel/TimeSlider
@onready var time_label: Label = $ControlPanel/TimeLabel
@onready var char_container: HBoxContainer = $CharacterList/HBoxContainer
@onready var timeline_container: VBoxContainer = $TimelineContainer

signal inspection_requested(obj_name: String, obj_desc: String)

var planning_manager
var track_scene = preload("res://scenes/ui/TimelineTrack.tscn")
var loadout_ui: LoadoutUI
var _inspectable_objects: Array[Node] = []
var _current_obj_index: int = -1

func setup(manager) -> void:
	planning_manager = manager
	
	# Find all interactive objects for inspection
	_inspectable_objects = get_tree().get_nodes_in_group("interactive_objects")
	if _inspectable_objects.is_empty():
		var root = get_tree().current_scene
		_find_interactive_objects(root)

	_setup_loadout()
	_connect_manager_signals()
	refresh_character_list()
	refresh_timeline()

func _find_interactive_objects(node: Node):
	if node.is_in_group("interactive_objects") or node is InteractiveObject:
		_inspectable_objects.append(node)
	for child in node.get_children():
		_find_interactive_objects(child)

func _setup_loadout():
	if not loadout_ui:
		var scene = load("res://scenes/ui/LoadoutUI.tscn")
		if scene:
			loadout_ui = scene.instantiate()
			add_child(loadout_ui)
			loadout_ui.setup(planning_manager)
			loadout_ui.visible = false

func _connect_manager_signals():
	if planning_manager.ghost_controller:
		planning_manager.ghost_controller.time_changed.connect(_on_time_changed)
		planning_manager.ghost_controller.recording_finished.connect(func(_char): refresh_timeline())
	planning_manager.character_selected.connect(_on_character_selected)

func _ready() -> void:
	btn_rec.pressed.connect(_on_rec_pressed)
	btn_stop.pressed.connect(_on_stop_pressed)
	btn_play.pressed.connect(_on_play_pressed)
	if btn_wait: btn_wait.pressed.connect(_on_wait_pressed)
	if btn_equip: btn_equip.pressed.connect(_on_equip_pressed)
	if btn_next_obj: btn_next_obj.pressed.connect(_on_next_obj_pressed)
	if btn_prev_obj: btn_prev_obj.pressed.connect(_on_prev_obj_pressed)

func _on_next_obj_pressed():
	if _inspectable_objects.is_empty(): return
	_current_obj_index = (_current_obj_index + 1) % _inspectable_objects.size()
	_inspect_current()

func _on_prev_obj_pressed():
	if _inspectable_objects.is_empty(): return
	_current_obj_index = (_current_obj_index - 1 + _inspectable_objects.size()) % _inspectable_objects.size()
	_inspect_current()

func _inspect_current():
	var obj = _inspectable_objects[_current_obj_index]
	var obj_name = obj.object_name if "object_name" in obj else obj.name
	var obj_desc = "Zabezpečený prvek. Typ: " + obj.get_class()
	
	if "is_locked" in obj:
		obj_desc += " | STAV: " + ("ZAMČENO" if obj.is_locked else "OTEVŘENO")
	if "has_alarm" in obj and obj.has_alarm:
		obj_desc += " | ⚠️ ALARM AKTIVNÍ"
		
	inspection_requested.emit(obj_name, obj_desc)

func _on_equip_pressed() -> void:
	if loadout_ui:
		loadout_ui.visible = true
		loadout_ui._refresh_stash()
		loadout_ui._refresh_team()

func refresh_character_list() -> void:
	if not char_container: return
	
	for child in char_container.get_children():
		child.queue_free()
		
	if not planning_manager: return
	
	var idx = 0
	for char_data in planning_manager.team:
		var btn = Button.new()
		btn.text = char_data.name.left(1) # Initials
		btn.custom_minimum_size = Vector2(50, 50)
		btn.toggle_mode = true
		btn.focus_mode = Control.FOCUS_NONE 
		
		# Capture index for callback
		var char_index = idx
		btn.pressed.connect(func(): planning_manager.select_character(char_index))
		
		char_container.add_child(btn)
		idx += 1

func refresh_timeline() -> void:
	if not timeline_container or not planning_manager: return
	
	for child in timeline_container.get_children():
		child.queue_free()
		
	for char_data in planning_manager.team:
		var track_instance = track_scene.instantiate()
		timeline_container.add_child(track_instance)
		
		var blocks = planning_manager.ghost_controller.analyze_track(char_data.name)
		track_instance.setup(char_data.name, blocks, 600.0)

func _on_character_selected(character: CharacterData) -> void:
	if not char_container: return
	
	var idx = 0
	for btn in char_container.get_children():
		var is_selected = (planning_manager.team[idx] == character)
		btn.set_pressed_no_signal(is_selected)
		idx += 1

func _on_rec_pressed() -> void:
	if planning_manager:
		planning_manager.start_recording_current()
		_update_status("NAHRÁVÁNÍ")

func _on_stop_pressed() -> void:
	if planning_manager:
		planning_manager.commit_current_recording()
		_update_status("STOP")

func _on_play_pressed() -> void:
	if planning_manager and planning_manager.ghost_controller:
		planning_manager.ghost_controller.play_simulation()
		_update_status("PŘEHRÁVÁNÍ")

func _on_wait_pressed() -> void:
	if planning_manager and planning_manager.team.size() > 0:
		var char_data = planning_manager.team[planning_manager.selected_character_index]
		var current_time = time_slider.value
		planning_manager.add_wait_action(char_data, current_time, 2.0) # Default 2s wait
		refresh_timeline()

func _on_time_changed(new_time: float) -> void:
	if time_slider: time_slider.value = new_time
	if time_label: time_label.text = "%.2f s" % new_time

func _update_status(_text: String) -> void:
	pass
