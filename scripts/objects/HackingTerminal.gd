extends InteractiveObject

@export var difficulty: float = 1.0
@export var money_reward: int = 2000
@export var is_hacked: bool = false
@export var is_main_objective: bool = true
@export var shuts_down_security: bool = false

func _on_interact(_agent: Node) -> void:
	if not is_hacked:
		EventBus.request_hacking_minigame.emit(difficulty, _on_hacking_success)
	else:
		print("Terminal already hacked.")

func _on_hacking_success(success: bool):
	if success:
		is_hacked = true
		EconomyManager.wallet += money_reward
		
		if shuts_down_security:
			EventBus.security_shutdown_requested.emit(object_name)
			print("Security shutdown triggered by ", object_name)
		
		if is_main_objective:
			GameManager.main_loot_collected = true
			print("Data stolen! Main objective complete.")
			
		# Visual feedback
		if has_node("Label"):
			$Label.text = "HACKED"
			$Label.modulate = Color.GREEN
		
		print("Hacking successful! Reward: ", money_reward)
	else:
		print("Hacking failed!")