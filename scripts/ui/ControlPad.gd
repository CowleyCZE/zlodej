extends Control

# ControlPad.gd
# Simuluje vstupy klávesnice pro pohyb

func _ready():
	# Připojíme signály button_down a button_up dynamicky nebo v editoru
	# Zde předpokládáme názvy nodů z tscn
	_connect_button("PanelContainer/VBoxContainer/HBoxContainer/Up", "ui_up")
	_connect_button("PanelContainer/VBoxContainer/HBoxContainer2/Down", "ui_down")
	_connect_button("PanelContainer/VBoxContainer/HBoxContainer2/Left", "ui_left")
	_connect_button("PanelContainer/VBoxContainer/HBoxContainer2/Right", "ui_right")

func _connect_button(path, action):
	var btn = get_node_or_null(path)
	if btn:
		btn.button_down.connect(func(): Input.action_press(action))
		btn.button_up.connect(func(): Input.action_release(action))

func _on_undo_pressed():
	# Undo logic needs specific implementation in controller
	pass

func _on_center_camera_pressed():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var cam = player.find_child("TacticalCamera")
		if cam:
			cam.reset_offset()