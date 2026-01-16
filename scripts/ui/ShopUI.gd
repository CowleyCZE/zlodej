extends Control

@onready var money_label = $TopPanel/Margin/HBox/PlayerMoney
@onready var item_rows = $MainLayout/ListPanel/VBox/Scroll/ItemRows
@onready var detail_image = $MainLayout/DetailPanel/Margin/VBox/ImageFrame/Image
@onready var detail_name = $MainLayout/DetailPanel/Margin/VBox/Name
@onready var detail_description = $MainLayout/DetailPanel/Margin/VBox/Description
@onready var detail_price = $MainLayout/DetailPanel/Margin/VBox/HBox/Price
@onready var btn_buy = $MainLayout/DetailPanel/Margin/VBox/Btn_Buy

var selected_item_id: String = ""

func _ready():
	_update_money_display()
	$Btn_Exit.pressed.connect(_on_Btn_Exit_pressed)
	btn_buy.pressed.connect(_on_Btn_Buy_pressed)
	btn_buy.disabled = true
	
	_populate_shop()
	EventBus.wallet_changed.connect(func(_a): _update_money_display())

func _update_money_display():
	money_label.text = "%d CZK" % EconomyManager.wallet

func _populate_shop():
	for child in item_rows.get_children():
		child.queue_free()
	
	for item_id in EconomyManager.item_db:
		var item = EconomyManager.item_db[item_id]
		var btn = Button.new()
		btn.text = "%s (%d CZK)" % [item.name, item.price]
		btn.custom_minimum_size.y = 55
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.pressed.connect(_on_item_selected.bind(item_id))
		item_rows.add_child(btn)

func _on_item_selected(id: String):
	selected_item_id = id
	var item = EconomyManager.item_db[id]
	detail_name.text = item.name.to_upper()
	detail_description.text = item.description
	detail_price.text = "%d CZK" % item.price
	
	# Handle icon if exists
	# if item.icon_path: detail_image.texture = load(item.icon_path)
	
	btn_buy.disabled = EconomyManager.wallet < item.price
	if btn_buy.disabled:
		btn_buy.text = "NEDOSTATEK FINANCÍ"
	else:
		btn_buy.text = "POTVRDIT NÁKUP"

func _on_Btn_Buy_pressed():
	if selected_item_id == "": return
	
	if EconomyManager.purchase(selected_item_id):
		# Success feedback
		var tween = create_tween()
		tween.tween_property(btn_buy, "modulate", Color.GREEN, 0.1)
		tween.tween_property(btn_buy, "modulate", Color.WHITE, 0.2)
		_on_item_selected(selected_item_id) # Refresh button state
		print("Shop: Zakoupeno ", selected_item_id)
	else:
		# Failure feedback
		var tween = create_tween()
		tween.tween_property(btn_buy, "modulate", Color.RED, 0.1)
		tween.tween_property(btn_buy, "modulate", Color.WHITE, 0.2)

func _on_Btn_Exit_pressed():
	# Use standard Game UI closure
	var game = get_tree().root.find_child("Game", true, false)
	if game and game.has_method("close_current_ui"):
		game.close_current_ui()
	else:
		queue_free()
