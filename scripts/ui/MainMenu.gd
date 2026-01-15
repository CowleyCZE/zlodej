extends Control

@onready var btn_continue = $MenuContainer/Btn_Continue
@onready var btn_new_game = $MenuContainer/Btn_NewGame
@onready var btn_settings = $MenuContainer/Btn_Settings
@onready var btn_credits = $MenuContainer/Btn_Credits
@onready var btn_quit = $MenuContainer/Btn_Quit

func _ready():
	btn_new_game.pressed.connect(_on_new_game_pressed)
	btn_quit.pressed.connect(_on_quit_pressed)
	# Connect other buttons as placeholders
	btn_settings.pressed.connect(func(): print("Settings clicked"))
	btn_credits.pressed.connect(func(): print("Credits clicked"))

	# Check for save game to enable continue (placeholder check)
	if SaveManager.has_method("save_exists") and SaveManager.save_exists():
		btn_continue.disabled = false
		btn_continue.pressed.connect(_on_continue_pressed)
	else:
		btn_continue.disabled = true

func _on_new_game_pressed():
	# Start new game flow -> Name Selection
	get_tree().change_scene_to_file("res://scenes/ui/NameSelection.tscn")

func _on_continue_pressed():
	# EventBus.request_continue_game.emit() # Future
	pass

func _on_quit_pressed():
	EventBus.request_quit_game.emit()
