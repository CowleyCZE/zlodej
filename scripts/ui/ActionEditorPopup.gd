class_name ActionEditorPopup
extends Window

signal data_changed(action_index: int, changes: Dictionary)
signal action_deleted(action_index: int)

var current_char: CharacterData
var current_action_index: int
var current_action: PlanningData.TimelineAction

# UI References (created in code for MVP if scene doesn't exist, or expected nodes)
var vbox: VBoxContainer
var lbl_info: Label
var opt_tools: OptionButton
var txt_wait_signal: LineEdit
var txt_emit_signal: LineEdit
var btn_save: Button
var btn_delete: Button

func _ready() -> void:
	title = "Upravit Akci"
	initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
	size = Vector2(300, 250)
	exclusive = true
	visible = false
	
	# Create UI programmatically to avoid dependency on .tscn for now
	var margin = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 10)
	add_child(margin)
	
	vbox = VBoxContainer.new()
	margin.add_child(vbox)
	
	lbl_info = Label.new()
	vbox.add_child(lbl_info)
	
	vbox.add_child(Label.new().with_text("Nástroj:"))
	opt_tools = OptionButton.new()
	vbox.add_child(opt_tools)
	
	vbox.add_child(Label.new().with_text("Čekat na signál:"))
	txt_wait_signal = LineEdit.new()
	txt_wait_signal.placeholder_text = "např. alarm_disabled"
	vbox.add_child(txt_wait_signal)
	
	vbox.add_child(Label.new().with_text("Vyslat signál po dokončení:"))
	txt_emit_signal = LineEdit.new()
	txt_emit_signal.placeholder_text = "např. door_open"
	vbox.add_child(txt_emit_signal)
	
	vbox.add_child(HSeparator.new())
	
	var hbox_btns = HBoxContainer.new()
	vbox.add_child(hbox_btns)
	
	btn_save = Button.new()
	btn_save.text = "Uložit"
	btn_save.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_save.pressed.connect(_on_save_pressed)
	hbox_btns.add_child(btn_save)
	
	btn_delete = Button.new()
	btn_delete.text = "Smazat"
	btn_delete.modulate = Color.RED
	btn_delete.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_delete.pressed.connect(_on_delete_pressed)
	hbox_btns.add_child(btn_delete)
	
	close_requested.connect(hide)

# Helper extension for Label
func with_text(t: String) -> Label:
	self.text = t
	return self

func open(char_data: CharacterData, action_index: int, action: PlanningData.TimelineAction):
	current_char = char_data
	current_action_index = action_index
	current_action = action
	
	# Populate fields
	lbl_info.text = "%s - %.1fs" % [action.type, action.time]
	
	# Tools
	opt_tools.clear()
	opt_tools.add_item("Žádný / Výchozí", 0)
	opt_tools.set_item_metadata(0, "")
	
	var idx = 1
	for item_id in char_data.inventory:
		# Need lookup for item name, simplified here:
		opt_tools.add_item(item_id, idx)
		opt_tools.set_item_metadata(idx, item_id)
		if item_id == action.selected_tool_id:
			opt_tools.selected = idx
		idx += 1
		
	txt_wait_signal.text = action.wait_for_signal
	txt_emit_signal.text = action.emit_signal_on_complete
	
	popup()

func _on_save_pressed():
	var changes = {}
	
	# Tool
	if opt_tools.selected > -1:
		changes["tool_id"] = opt_tools.get_selected_metadata()
	else:
		changes["tool_id"] = ""
		
	changes["wait_signal"] = txt_wait_signal.text
	changes["emit_signal"] = txt_emit_signal.text
	
	data_changed.emit(current_action_index, changes)
	hide()

func _on_delete_pressed():
	action_deleted.emit(current_action_index)
	hide()
