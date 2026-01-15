extends Control

var time_left: float = 30.0
var target_sequence: Array = []
var player_sequence: Array = []
var sequence_length: int = 4
var completion_callback: Callable

@onready var grid_container = $Terminal/GridContainer
@onready var sequence_label = $Terminal/TargetSequence
@onready var time_label = $Terminal/TimerLabel

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func setup(difficulty: float, callback: Callable):
	completion_callback = callback
	sequence_length = 3 + int(difficulty)
	time_left = 40.0 / difficulty
	
	_generate_puzzle()

func _generate_target_sequence():
	target_sequence.clear()
	for i in range(sequence_length):
		target_sequence.append(randi() % 10)
	sequence_label.text = "TARGET: " + "".join(target_sequence.map(func(n): return str(n)))

func _generate_puzzle():
	_generate_target_sequence()
	
	# Clear grid
	for child in grid_container.get_children():
		child.queue_free()
	
	# Prepare a list of numbers for the 16 slots
	var grid_numbers = []
	# 1. Add all required target numbers first to ensure they exist
	for n in target_sequence:
		grid_numbers.append(n)
	
	# 2. Fill the rest with random numbers
	while grid_numbers.size() < 16:
		grid_numbers.append(randi() % 10)
	
	# 3. Shuffle the numbers so the target isn't at the start
	grid_numbers.shuffle()
	
	# 4. Create buttons
	for num in grid_numbers:
		var btn = Button.new()
		btn.text = str(num)
		btn.custom_minimum_size = Vector2(60, 60)
		btn.pressed.connect(func(): _on_number_pressed(num))
		grid_container.add_child(btn)

func _on_number_pressed(num):
	if player_sequence.size() < target_sequence.size():
		if num == target_sequence[player_sequence.size()]:
			player_sequence.append(num)
			$Terminal/Status.text = "CORRECT: " + "".join(player_sequence.map(func(n): return str(n)))
			$Terminal/Status.modulate = Color.GREEN
			if player_sequence.size() == target_sequence.size():
				_success()
		else:
			player_sequence.clear()
			$Terminal/Status.text = "ERROR - SEQUENCE RESET"
			$Terminal/Status.modulate = Color.RED
			# Maybe reduce time on error
			time_left -= 2.0

func _process(delta):
	time_left -= delta
	time_label.text = "SEC: " + str(max(0, int(time_left)))
	
	if time_left <= 0:
		_fail()

func _success():
	set_process(false)
	$Terminal/Status.text = "ACCESS GRANTED"
	await get_tree().create_timer(1.0).timeout
	if completion_callback.is_valid():
		completion_callback.call(true)
	
	var game = get_tree().root.find_child("Game", true, false)
	if game and game.has_method("close_current_ui"):
		game.close_current_ui()
	else:
		queue_free()

func _fail():
	set_process(false)
	$Terminal/Status.text = "SYSTEM LOCKED"
	$Terminal/Status.modulate = Color.RED
	await get_tree().create_timer(1.0).timeout
	if completion_callback.is_valid():
		completion_callback.call(false)
	
	var game = get_tree().root.find_child("Game", true, false)
	if game and game.has_method("close_current_ui"):
		game.close_current_ui()
	else:
		queue_free()
