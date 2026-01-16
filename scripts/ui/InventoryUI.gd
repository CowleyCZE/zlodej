extends Control

@onready var item_grid = $MainPanel/Layout/LeftColumn/ScrollContainer/ItemGrid
@onready var weight_bar = $MainPanel/Layout/LeftColumn/WeightBar
@onready var detail_name = $MainPanel/Layout/RightColumn_Details/ItemName
@onready var detail_desc = $MainPanel/Layout/RightColumn_Details/ItemDescription
@onready var detail_weight = $MainPanel/Layout/RightColumn_Details/Stats/WeightLine/WeightValue

var selected_item_id: String = ""

func _ready():
	update_inventory_display()
	InventoryManager.inventory_updated.connect(update_inventory_display)
	
	$MainPanel/Layout/RightColumn_Details/Btn_Close.pressed.connect(_on_Btn_Close_pressed)
	$MainPanel/Layout/RightColumn_Details/Btn_Drop.pressed.connect(_on_Btn_Drop_pressed)
	
	# Close on Escape
	set_process_unhandled_input(true)

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("open_inventory"):
		_on_Btn_Close_pressed()

func update_inventory_display():
	# Clear existing children
	if item_grid:
		for child in item_grid.get_children():
			child.queue_free()
	
	# Populate from InventoryManager
	for entry in InventoryManager.items:
		var item = entry.item
		var quantity = entry.quantity
		
		var container = VBoxContainer.new()
		var btn = Button.new()
		btn.text = "x" + str(quantity)
		btn.custom_minimum_size = Vector2(120, 100)
		btn.pressed.connect(_on_item_selected.bind(item))
		
		# Stylized item name inside button or below
		var lbl = Label.new()
		lbl.text = item.name
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		
		container.add_child(btn)
		container.add_child(lbl)
		
		if item_grid:
			item_grid.add_child(container)
	
	# Update weight bar
	if weight_bar:
		weight_bar.max_value = InventoryManager.max_weight
		weight_bar.value = InventoryManager.current_weight
		weight_bar.tooltip_text = "Váha: %.1f / %.1f kg" % [InventoryManager.current_weight, InventoryManager.max_weight]


func _on_item_selected(item: InventoryItem):
	selected_item_id = item.id
	if detail_name: detail_name.text = item.name
	if detail_desc: detail_desc.text = item.description
	if detail_weight: detail_weight.text = str(item.weight) + " kg"

func _on_Btn_Use_pressed():
	pass # Replace with actual logic

func _on_Btn_Drop_pressed():
	if selected_item_id != "":
		InventoryManager.remove_item(selected_item_id, 1)
		# Clear details if item is gone
		if not InventoryManager.has_item(selected_item_id):
			if detail_name: detail_name.text = "Vyber předmět"
			if detail_desc: detail_desc.text = ""
			if detail_weight: detail_weight.text = "0 kg"
			selected_item_id = ""

func _on_Btn_Close_pressed():
	var game = get_tree().root.find_child("Game", true, false)
	if game and game.has_method("close_current_ui"):
		game.close_current_ui()
	else:
		queue_free()
