extends Control

var target_angle: float = 0.0
var current_pick_angle: float = 0.0
var lock_rotation: float = 0.0
var difficulty_range: float = 15.0 # Degrees of tolerance
var completion_callback: Callable

@onready var pick_visual = $LockContainer/Pick
@onready var lock_visual = $LockContainer/Cylinder

func _ready():
	# Randomize the sweet spot
	target_angle = randf_range(-90, 90)
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func setup(difficulty: float, callback: Callable):
	difficulty_range = 20.0 / difficulty # Higher difficulty = smaller range
	completion_callback = callback

func _process(_delta):
	# Mouse horizontal movement controls the pick angle
	var mouse_pos = get_local_mouse_position()
	var center = size / 2.0
	var vector = mouse_pos - center
	current_pick_angle = rad_to_deg(vector.angle())
	
	# Clamp angle to top half for realism
	current_pick_angle = clamp(current_pick_angle, -180, 0)
	pick_visual.rotation_degrees = current_pick_angle + 90
	
	if Input.is_action_pressed("ui_right") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		attempt_turn()
	else:
		# Gradually return lock to zero
		lock_rotation = lerp(lock_rotation, 0.0, 0.1)
		lock_visual.rotation_degrees = lock_rotation

func attempt_turn():
	# Calculate how close we are to the sweet spot (using top-centered coordinates)
	# Target is actually between -90 and 90 relative to the top
	var normalized_pick = current_pick_angle + 90
	var distance = abs(normalized_pick - target_angle)
	
	var max_turn = 0.0
	if distance < difficulty_range:
		max_turn = 90.0 # Can turn all the way
	else:
		# Can only turn partially depending on distance
		max_turn = clamp(90.0 - (distance * 2.0), 0.0, 45.0)
	
	lock_rotation = move_toward(lock_rotation, max_turn, 2.0)
	lock_visual.rotation_degrees = lock_rotation
	
	if lock_rotation >= 89.0:
		success()

func success():
	set_process(false)
	$StatusLabel.text = "ODEMČENO!"
	$StatusLabel.modulate = Color.GREEN
	await get_tree().create_timer(1.0).timeout
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if completion_callback.is_valid():
		completion_callback.call(true)
	
	var game = get_tree().root.find_child("Game", true, false)
	if game and game.has_method("close_current_ui"):
		game.close_current_ui()
	else:
		queue_free()

func fail():
	# Logic for broken pick
	pass

func _exit_tree():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
