extends PanelContainer

signal time_confirmed(value: int)
signal cancelled

var display_label: Label
var current_string: String = ""
var max_length: int = 4

func _ready():
	# Build UI programmatically since we can't rely on .tscn file creation
	_build_ui()
	visible = false

func _build_ui():
	# Setup Main Panel
	anchors_preset = Control.PRESET_CENTER
	custom_minimum_size = Vector2(200, 300)
	# Center on screen (requires parent to be full rect or similar, usually CanvasLayer)
	# We'll set offsets manually or let layout handle it if parent is suitable.
	# For popup-like behavior:
	set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	
	var vbox = VBoxContainer.new()
	add_child(vbox)
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Display
	var display_panel = Panel.new()
	display_panel.custom_minimum_size = Vector2(0, 50)
	vbox.add_child(display_panel)
	
	display_label = Label.new()
	display_label.text = "0"
	display_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	display_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	display_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	display_panel.add_child(display_label)
	
	# Grid
	var grid = GridContainer.new()
	grid.columns = 3
	vbox.add_child(grid)
	
	# Buttons 1-9
	for i in range(1, 10):
		var btn = Button.new()
		btn.text = str(i)
		btn.custom_minimum_size = Vector2(40, 40)
		btn.pressed.connect(_on_number_pressed.bind(str(i)))
		grid.add_child(btn)
		
	# Clear
	var btn_clear = Button.new()
	btn_clear.text = "C"
	btn_clear.pressed.connect(_on_clear_pressed)
	grid.add_child(btn_clear)
	
	# 0
	var btn_0 = Button.new()
	btn_0.text = "0"
	btn_0.pressed.connect(_on_number_pressed.bind("0"))
	grid.add_child(btn_0)
	
	# OK
	var btn_ok = Button.new()
	btn_ok.text = "OK"
	btn_ok.pressed.connect(_on_ok_pressed)
	grid.add_child(btn_ok)
	
	# Cancel
	var btn_cancel = Button.new()
	btn_cancel.text = "Zrušit"
	btn_cancel.pressed.connect(_on_cancel_pressed)
	vbox.add_child(btn_cancel)

func open():
	current_string = ""
	_update_display()
	visible = true
	move_to_front()
	# Center again just in case
	set_anchors_and_offsets_preset(Control.PRESET_CENTER)

func _on_number_pressed(num_str):
	if current_string.length() < max_length:
		current_string += num_str
		_update_display()

func _on_clear_pressed():
	current_string = ""
	_update_display()

func _on_ok_pressed():
	if current_string.is_empty():
		return
	var value = int(current_string)
	if value > 0:
		time_confirmed.emit(value)
		visible = false

func _on_cancel_pressed():
	cancelled.emit()
	visible = false

func _update_display():
	if current_string == "":
		display_label.text = "0"
	else:
		display_label.text = current_string
