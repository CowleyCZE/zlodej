extends PanelContainer

signal time_scrubbed(value: float)

@onready var tracks_container = $VBoxContainer/TracksContainer
@onready var time_slider = $VBoxContainer/TimeSlider
@onready var time_label = $VBoxContainer/Header/TimeDisplay
@onready var btn_play = $VBoxContainer/Header/PlaybackControls/BtnPlay
@onready var btn_stop = $VBoxContainer/Header/PlaybackControls/BtnStop
@onready var btn_restart = $VBoxContainer/Header/PlaybackControls/BtnRestart

var track_scene = preload("res://scenes/ui/TimelineTrack.tscn")
var active_tracks = {}
var is_playing: bool = false
var playback_total_time: float = 600.0 # Default 10 min
var planning_manager: PlanningManager
var action_editor: ActionEditorPopup

func _ready():
	time_slider.value_changed.connect(_on_slider_changed)
	btn_play.pressed.connect(_on_play_pressed)
	btn_stop.pressed.connect(_on_stop_pressed)
	btn_restart.pressed.connect(_on_restart_pressed)
	
	# Create Editor Popup
	action_editor = ActionEditorPopup.new()
	add_child(action_editor)
	action_editor.data_changed.connect(_on_action_edited)
	action_editor.action_deleted.connect(_on_action_deleted)
	
	# Attempt to find PlanningManager if not injected
	if not planning_manager:
		# Assuming PlanningManager is available globally or via a specific path in the main scene
		# Ideally, this should be injected by the parent controller
		var main = get_tree().current_scene
		if main.has_node("PlanningManager"):
			planning_manager = main.get_node("PlanningManager")
			
	if planning_manager:
		planning_manager.plan_updated.connect(_on_plan_updated)
		planning_manager.character_selected.connect(_on_character_selected)

func initialize(manager: PlanningManager):
	planning_manager = manager
	planning_manager.plan_updated.connect(_on_plan_updated)
	planning_manager.character_selected.connect(_on_character_selected)
	_refresh_ui()

func _refresh_ui():
	# Clear existing tracks
	for child in tracks_container.get_children():
		child.queue_free()
	active_tracks.clear()
	
	if not planning_manager or not planning_manager.current_plan:
		return
		
	playback_total_time = planning_manager.current_plan.timeline_duration
	
	# Create a track for each team member
	for char_data in planning_manager.team:
		var track = track_scene.instantiate()
		tracks_container.add_child(track)
		
		# Get the plan for this character
		var plan = planning_manager.current_plan.get_or_create_plan_for(char_data)
		track.setup_from_plan(char_data, plan, playback_total_time)
		track.action_clicked.connect(_on_track_action_clicked)
		
		active_tracks[char_data.name] = track

func _on_plan_updated():
	_refresh_ui()

func _on_character_selected(_char_data: CharacterData):
	# Highlight the selected character's track?
	pass

func _on_track_action_clicked(char_data: CharacterData, action_index: int):
	# Open editor
	var plan = planning_manager.current_plan.get_or_create_plan_for(char_data)
	if action_index >= 0 and action_index < plan.actions.size():
		var action = plan.actions[action_index]
		action_editor.open(char_data, action_index, action)

func _on_action_edited(action_index: int, changes: Dictionary):
	var char_data = action_editor.current_char
	
	if changes.has("tool_id"):
		planning_manager.assign_tool_to_action(char_data, action_index, changes["tool_id"])
		
	if changes.has("wait_signal"):
		planning_manager.add_synchronization_wait(char_data, action_index, changes["wait_signal"])
		
	if changes.has("emit_signal"):
		planning_manager.set_action_emit_signal(char_data, action_index, changes["emit_signal"])

func _on_action_deleted(action_index: int):
	var char_data = action_editor.current_char
	planning_manager.remove_action(char_data, action_index)

func _process(delta):
	if is_playing and playback_total_time > 0:
		var step = delta / playback_total_time
		var new_val = time_slider.value + step
		if new_val >= 1.0:
			new_val = 1.0
			is_playing = false
		time_slider.value = new_val
		
		# Update visualization time
		# TODO: feedback to PlanningManager for preview?

func _on_play_pressed():
	if playback_total_time > 0:
		is_playing = true

func _on_stop_pressed():
	is_playing = false

func _on_restart_pressed():
	is_playing = false
	time_slider.value = 0.0

func _on_slider_changed(value: float):
	time_scrubbed.emit(value * playback_total_time)
