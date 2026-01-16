extends InteractiveObject

@export var value: int = 1000
@export var weight: float = 1.0
@export var is_main_objective: bool = false

func _on_interact(_agent: Node) -> void:
	print("Sebrán loot: ", object_name, " (", value, " CZK)")
	
	if is_main_objective:
		GameManager.main_loot_collected = true
		print("Main objective collected!")
	
	# Update Mission State via EventBus
	EconomyManager.wallet += value
	
	# Hide instead of delete to allow resets
	visible = false
	$Area2D.set_deferred("monitorable", false)
	$Area2D.set_deferred("monitoring", false)
