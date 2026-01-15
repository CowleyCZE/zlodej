extends Control

func _ready():
	$CenterContainer/VBoxContainer/Btn_Resume.pressed.connect(_on_resume_pressed)
	$CenterContainer/VBoxContainer/Btn_Settings.pressed.connect(_on_settings_pressed)
	$CenterContainer/VBoxContainer/Btn_QuitToMenu.pressed.connect(_on_quit_to_menu_pressed)

func _on_resume_pressed():
	var main = get_tree().get_root().get_node("Main")
	if main:
		main.close_current_ui()

func _on_settings_pressed():
	print("Settings clicked")

func _on_quit_to_menu_pressed():
	var main = get_tree().get_root().get_node("Main")
	if main:
		main.close_current_ui()
		main.change_scene_to("res://scenes/ui/MainMenu.tscn")
