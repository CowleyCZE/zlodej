extends Control

@onready var money_label = $MarginContainer/VBoxContainer/MoneyLabel
@onready var objective_label = $MarginContainer/VBoxContainer/ObjectiveLabel

var indicator_scene = preload("res://scenes/ui/DetectionIndicator.tscn")

func _ready():
	update_hud()
	# Connect to relevant signals
	EventBus.inventory_changed.connect(update_hud)
	EventBus.wallet_changed.connect(update_hud_wallet) # Fix: use correct signal
	EventBus.mission_loot_changed.connect(func(_total): update_hud())
	EventBus.mission_started.connect(_on_mission_started)
	
	add_to_group("hud")

func update_hud():
	money_label.text = "Peníze: " + str(EconomyManager.wallet) + " CZK"
	if GameManager.current_mission_loot > 0:
		money_label.text += " (+ " + str(GameManager.current_mission_loot) + " lupu)"

func update_hud_wallet(amount):
	money_label.text = "Peníze: " + str(amount) + " CZK"

func _on_mission_started(_mission_id):
	objective_label.text = "Úkol: Ukradni loot a zmiz!"
	objective_label.show()

func spawn_detection_indicator(guard_node, player_node):
	var indicator = indicator_scene.instantiate()
	add_child(indicator)
	indicator.setup(guard_node, player_node)
