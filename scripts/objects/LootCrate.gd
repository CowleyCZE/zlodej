extends StaticBody3D

@export var money_amount: int = 1000
@export var is_locked: bool = false
@export var lock_difficulty: float = 1.0

var is_collected: bool = false

func _ready():
	add_to_group("interactive")
	update_label()

func interact():
	if is_collected: return
	
	if is_locked:
		print("LootCrate: Zamčeno. Vyžaduje páčení.")
		EventBus.request_lockpick_minigame.emit(lock_difficulty, _on_lockpick_success)
	else:
		collect()

func _on_lockpick_success(success: bool):
	if success:
		is_locked = false
		print("LootCrate: Odemčeno!")
		collect()
	else:
		print("LootCrate: Páčení selhalo.")

func collect():
	if is_collected: return
	is_collected = true
	
	GameManager.current_mission_loot += money_amount
	EventBus.mission_loot_changed.emit(GameManager.current_mission_loot)
	
	print("Sebráno: ", money_amount, " CZK")
	
	# Vizuální zpětná vazba
	if has_node("Label3D"):
		$Label3D.text = "SEBRÁNO"
		$Label3D.modulate = Color.GREEN
	
	# Po chvíli zmizí nebo se deaktivuje
	await get_tree().create_timer(1.0).timeout
	visible = false
	process_mode = PROCESS_MODE_DISABLED

func update_label():
	if has_node("Label3D"):
		if is_locked:
			$Label3D.text = "ZAMČENO (Páčit)"
		else:
			$Label3D.text = "LOOT (%d CZK)" % money_amount
