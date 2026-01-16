extends InteractiveObject

class_name Trezor

@export var is_locked: bool = true
@export var loot_value: int = 10000

var available_actions: Array = ["Vrtat", "Páčit"]

func _ready():
	object_name = "Trezor"
	if required_tool == "":
		required_tool = "drill"

func _on_interact(_agent: Node) -> void:
	if is_locked:
		_unlock()
	else:
		_collect_loot()

func _unlock():
	is_locked = false
	modulate = Color(0.7, 1.0, 0.7) 
	if has_node("Label"):
		$Label.text = "OTEVŘENO"

func _collect_loot():
	EconomyManager.add_money(loot_value)
	queue_free()
