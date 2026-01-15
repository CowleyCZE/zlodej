class_name RecordingHUD
extends Control

@onready var btn_rec: Button = $ControlPanel/HBox/Btn_Rec
@onready var btn_stop: Button = $ControlPanel/HBox/Btn_Stop
@onready var btn_play: Button = $ControlPanel/HBox/Btn_Play
@onready var time_slider: HSlider = $ControlPanel/TimeSlider
@onready var time_label: Label = $ControlPanel/TimeLabel
@onready var char_container: HBoxContainer = $CharacterList/HBoxContainer
@onready var timeline_container: VBoxContainer = $TimelineContainer

var planning_manager
var track_scene = preload("res://scenes/ui/TimelineTrack.tscn")

func setup(manager) -> void:
	planning_manager = manager
	if planning_manager.ghost_controller:
		planning_manager.ghost_controller.time_changed.connect(_on_time_changed)
		planning_manager.ghost_controller.recording_finished.connect(func(_char): refresh_timeline())
	
	planning_manager.character_selected.connect(_on_character_selected)
	refresh_character_list()
	refresh_timeline()

func _ready() -> void:
	btn_rec.pressed.connect(_on_rec_pressed)
	btn_stop.pressed.connect(_on_stop_pressed)
	btn_play.pressed.connect(_on_play_pressed)

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

func _on_time_changed(new_time: float) -> void:
	time_slider.value = new_time
	time_label.text = "%.2f s" % new_time

func _update_status(_text: String) -> void:
	# Optional visual feedback
	pass
