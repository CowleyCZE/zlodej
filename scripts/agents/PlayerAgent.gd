class_name PlayerAgent
extends CharacterBody2D

enum Mode { MANUAL, PLAYBACK }

@export var speed: float = 200.0

# References
var ghost_controller: GhostRunController
var character_data: CharacterData
var current_mode: Mode = Mode.MANUAL

# Visuals
@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label
@onready var interaction_zone: Area2D = $InteractionZone

# Noise State
var noise_tick_timer: float = 0.0
const NOISE_TICK_RATE: float = 0.4 # Seconds between noise emissions while moving

func _ready():
	add_to_group("player")

func setup(data: CharacterData, controller: GhostRunController) -> void:
	character_data = data
	ghost_controller = controller
	
	if character_data:
		label.text = character_data.name

func set_mode(new_mode: Mode) -> void:
	current_mode = new_mode
	set_physics_process(true)
	_update_visuals()

func _update_visuals():
	if current_mode == Mode.PLAYBACK:
		modulate.a = 0.5 # Ghost effect
	else:
		modulate.a = 1.0

func set_detection_warning(is_detected: bool):
	if is_detected:
		modulate = Color.RED
		if label: label.modulate = Color.RED
	else:
		_update_visuals() # Reset to default (ghost or manual)
		if label: label.modulate = Color.WHITE

func _physics_process(delta: float) -> void:
	match current_mode:
		Mode.MANUAL:
			_process_manual_input()
		Mode.PLAYBACK:
			pass # Handled by apply_state
			
	_process_noise_emission(delta)

func _process_noise_emission(delta: float):
	if velocity.length_squared() < 100.0: # Threshold for moving
		return
		
	noise_tick_timer -= delta
	if noise_tick_timer <= 0:
		noise_tick_timer = NOISE_TICK_RATE
		
		# Determine radius based on speed
		var speed_val = velocity.length()
		var radius = 100.0 # Default Walk
		
		if speed_val > speed * 1.5: # Running
			radius = 250.0
		elif speed_val < speed * 0.6: # Sneaking
			radius = 35.0
			
		NoiseSystem.emit_noise(global_position, radius)

func _process_manual_input() -> void:
	if _can_move_manually():
		var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		velocity = input_dir * speed
		move_and_slide()
		
		var success_interact = false
		var interacted_obj_name = ""
		
		if Input.is_action_just_pressed("interact"):
			var result_obj = _try_interact_and_get_obj()
			if result_obj:
				success_interact = true
				interacted_obj_name = result_obj.name # Or unique ID
		
		# Record Frame
		if ghost_controller:
			var actions = {}
			if success_interact:
				actions["interact"] = true
				actions["target_id"] = interacted_obj_name
			ghost_controller.record_frame(global_position, velocity, actions)
	else:
		velocity = Vector2.ZERO

func execute_plan_action(type: String, data: Dictionary) -> void:
	if type == "INTERACT":
		# Try to find object by ID first, or fallback to proximity
		var _target_id = data.get("target_id", "")
		var tool_id = data.get("tool_id", "")
		
		# MVP: Just try to interact with nearest for now, as finding by ID requires a registry
		_try_interact(tool_id)

func apply_state(state: Dictionary) -> void:
	if state.is_empty(): return
	
	if state.has("pos"):
		global_position = state["pos"]
	if state.has("vel"):
		velocity = state["vel"]
	
	# Playback Interaction is now handled by execute_plan_action via signals
	# But we keep movement playback here
	move_and_slide()

func _try_interact(tool_id: String = "") -> bool:
	var obj = _try_interact_and_get_obj()
	if obj:
		return obj.interact(self, tool_id)
	return false

func _try_interact_and_get_obj() -> Node:
	var overlaps = interaction_zone.get_overlapping_areas()
	var nearest_obj = null
	var min_dist = INF
	
	for area in overlaps:
		var parent = area.get_parent()
		if parent is InteractiveObject:
			var dist = global_position.distance_to(parent.global_position)
			if dist < min_dist:
				min_dist = dist
				nearest_obj = parent
	return nearest_obj

func _can_move_manually() -> bool:
	if not ghost_controller: return false
	if not ghost_controller.is_recording: return false
	if ghost_controller.active_character != character_data: return false
	return true

func _show_feedback(text: String):
	var lbl = Label.new()
	lbl.text = text
	lbl.modulate = Color.RED
	lbl.position = Vector2(-20, -60)
	add_child(lbl)
	
	var tween = create_tween()
	tween.tween_property(lbl, "position:y", -80.0, 1.0)
	tween.parallel().tween_property(lbl, "modulate:a", 0.0, 1.0)
	tween.tween_callback(lbl.queue_free)