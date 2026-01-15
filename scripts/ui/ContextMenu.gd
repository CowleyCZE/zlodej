extends PanelContainer

signal action_selected(action_name, target_object)

@onready var container = $VBoxContainer
var current_target = null

func _ready():
	mouse_filter = Control.MOUSE_FILTER_STOP

func open_menu(screen_position: Vector2, actions: Array, target):
	current_target = target
	position = screen_position
	
	for child in container.get_children():
		child.queue_free()
	
	for action in actions:
		var btn = Button.new()
		btn.text = action
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.pressed.connect(_on_button_pressed.bind(action))
		container.add_child(btn)
	
	var cancel_btn = Button.new()
	cancel_btn.text = "Zrušit"
	cancel_btn.modulate = Color.RED
	cancel_btn.pressed.connect(close_menu)
	container.add_child(cancel_btn)
	
	show()

func _on_button_pressed(action):
	emit_signal("action_selected", action, current_target)
	close_menu()

func close_menu():
	hide()
