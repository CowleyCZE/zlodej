extends Control

var time_left: float = 30.0
var target_sequence: Array = []
var player_sequence: Array = []
var sequence_length: int = 4
var completion_callback: Callable

@onready var grid_container = $Terminal/GridContainer
@onready var sequence_label = $Terminal/TargetSequence
@onready var time_label = $Terminal/TimerLabel
@onready var status_label = $Terminal/Status

var hex_chars = ["00", "A1", "B2", "C3", "FF", "E4", "D5", "10", "20", "30"]

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	# Apply CRT shader to the background if it's there
	if has_node("TerminalFilter"):
		$TerminalFilter.visible = PerformanceManager.use_complex_shaders()

func setup(difficulty: float, callback: Callable):
	completion_callback = callback
	sequence_length = 3 + int(difficulty)
	
	# Bonus time if player has hacking kit
	var base_time = 40.0 / difficulty
	if InventoryManager.has_item("hacking_kit"):
		base_time *= 1.5
		print("HACKING: Time bonus from Hacking Kit applied.")
		
	time_left = base_time
	_generate_puzzle()

func _generate_target_sequence():
	target_sequence.clear()
	for i in range(sequence_length):
		target_sequence.append(hex_chars.pick_random())
	sequence_label.text = "CÍLOVÝ KÓD: " + " ".join(target_sequence)

func _generate_puzzle():
	_generate_target_sequence()
	player_sequence.clear()
	status_label.text = "ZADEJTE PROTOKOL..."
	status_label.modulate = Color.CYAN
	
	# Clear grid
	for child in grid_container.get_children():
		child.queue_free()
	
	var grid_pool = []
	for s in target_sequence:
		grid_pool.append(s)
	
	while grid_pool.size() < 16:
		grid_pool.append(hex_chars.pick_random())
	
	grid_pool.shuffle()
	
	for code in grid_pool:
		var btn = Button.new()
		btn.text = code
		btn.custom_minimum_size = Vector2(80, 60)
		btn.add_theme_color_override("font_color", Color.GREEN)
		btn.pressed.connect(_on_code_pressed.bind(code, btn))
		grid_container.add_child(btn)

func _on_code_pressed(code: String, btn: Button):
	if player_sequence.size() < target_sequence.size():
		if code == target_sequence[player_sequence.size()]:
			player_sequence.append(code)
			btn.disabled = true
			btn.modulate = Color.DARK_GREEN
			status_label.text = "SHODA: " + " ".join(player_sequence)
			status_label.modulate = Color.GREEN
			AudioManager.play_tool_sfx("hacking_typing")
			
			if player_sequence.size() == target_sequence.size():
				_success()
		else:
			# Reset on error
			AudioManager.play_ui_sound("ui_error")
			_reset_sequence()
			time_left -= 3.0 # Penalty
			status_label.text = "CHYBA - RESET SEKVENCE"
			status_label.modulate = Color.RED
			_flash_red()

func _reset_sequence():
	player_sequence.clear()
	for btn in grid_container.get_children():
		btn.disabled = false
		btn.modulate = Color.WHITE

func _flash_red():
	var tween = create_tween()
	$Terminal.modulate = Color.RED
	tween.tween_property($Terminal, "modulate", Color.WHITE, 0.3)

func _process(delta):
	time_left -= delta
	time_label.text = "ČAS: %.1f s" % max(0, time_left)
	
	if time_left <= 0:
		_fail()

func _success():
	AudioManager.play_tool_sfx("hacking_success")
	set_process(false)
	status_label.text = "PŘÍSTUP POVOLEN"
	status_label.modulate = Color.GREEN
	await get_tree().create_timer(1.0).timeout
	if completion_callback.is_valid():
		completion_callback.call(true)
	_close()

func _fail():
	set_process(false)
	status_label.text = "SYSTÉM ZABLOKOVÁN"
	status_label.modulate = Color.RED
	await get_tree().create_timer(1.5).timeout
	if completion_callback.is_valid():
		completion_callback.call(false)
	_close()

func _close():
	var game = get_tree().root.find_child("Game", true, false)
	if game and game.has_method("close_current_ui"):
		game.close_current_ui()
	else:
		queue_free()
