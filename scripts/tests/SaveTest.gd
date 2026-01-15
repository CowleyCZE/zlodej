extends Node

func _ready():
	print("--- STARTING SAVE SYSTEM TEST ---")
	
	# 1. Setup state
	GameManager.player_name = "TestThief"
	GameManager.reputation = 42
	GameManager.heat_levels["melnik"] = 15.5
	EconomyManager.wallet = 12345
	
	# Clear and add some items
	InventoryManager.clear_inventory()
	var lp = EconomyManager.item_db["lockpick_set"]
	InventoryManager.add_item(lp, 2)
	
	# Mission intel
	if MissionDB.missions.size() > 0:
		var m = MissionDB.missions[0]
		m.is_address_known = true
		m.intel_flags["security"] = true
	
	print("Initial state set.")
	
	# 2. Save
	SaveManager.save_game()
	
	# 3. Mess up state
	GameManager.player_name = "WrongName"
	GameManager.reputation = 0
	GameManager.heat_levels["melnik"] = 0.0
	EconomyManager.wallet = 0
	InventoryManager.clear_inventory()
	if MissionDB.missions.size() > 0:
		var m = MissionDB.missions[0]
		m.is_address_known = false
		m.intel_flags["security"] = false
		
	print("State messed up.")
	
	# 4. Load
	SaveManager.load_game()
	
	# 5. Verify
	var success = true
	if GameManager.player_name != "TestThief": 
		print("FAIL: Name not restored: ", GameManager.player_name)
		success = false
	if GameManager.reputation != 42:
		print("FAIL: Reputation not restored: ", GameManager.reputation)
		success = false
	if GameManager.heat_levels["melnik"] != 15.5:
		print("FAIL: Heat not restored: ", GameManager.heat_levels["melnik"])
		success = false
	if EconomyManager.wallet != 12345:
		print("FAIL: Wallet not restored: ", EconomyManager.wallet)
		success = false
	if InventoryManager.items.size() == 0 or InventoryManager.items[0].item.id != "lockpick_set":
		print("FAIL: Inventory not restored.")
		success = false
		
	if MissionDB.missions.size() > 0:
		var m = MissionDB.missions[0]
		if not m.is_address_known or not m.intel_flags["security"]:
			print("FAIL: Mission intel not restored.")
			success = false
	
	if success:
		print("--- SAVE SYSTEM TEST PASSED ---")
	else:
		print("--- SAVE SYSTEM TEST FAILED ---")
		
	# Exit after test
	get_tree().quit()
