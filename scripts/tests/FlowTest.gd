extends Node

func _ready():
	print("--- STARTING FLOW TEST ---")
	
	print("TEST: Verifying Autoloads...")
	print("- StoryManager: ", StoryManager != null)
	print("- GameManager: ", GameManager != null)
	print("- EventBus: ", EventBus != null)
	print("- ProgressManager: ", ProgressManager != null)
	print("- MissionDB: ", MissionDB != null)

	# 1. Test Onboarding Flow
	print("TEST: Simulating name selection...")
	GameManager.set_player_name("Arsen Lupin")
	
	# Verify name is set
	if GameManager.player_name != "Arsen Lupin":
		print("FAIL: Name not set correctly!")
		get_tree().quit(1)
		
	# 2. Test Story Trigger
	print("TEST: Simulating entry to Adventure Mode...")
	# StoryManager listens to game_state_changed signal on EventBus
	GameManager.current_state = GameManager.State.ADVENTURE
	EventBus.game_state_changed.emit(GameManager.State.ADVENTURE)
	
	# Wait for StoryManager's timer (1.0s)
	print("TEST: Waiting for StoryManager triggers (2s)...")
	await get_tree().create_timer(2.5).timeout
	
	print("TEST: Checking story flags...")
	if not StoryManager.story_flags["tutorial_call_received"]:
		print("FAIL: Honza's call was not triggered!")
		print("StoryManager flags: ", StoryManager.story_flags)
		get_tree().quit(1)
		return
	else:
		print("SUCCESS: Honza's call triggered.")

	# 3. Test Mission Unlocking
	print("TEST: Checking mission unlocking...")
	if not "mission_tutorial" in ProgressManager.unlocked_missions:
		print("FAIL: Tutorial mission not unlocked!")
		print("Unlocked missions: ", ProgressManager.unlocked_missions)
		get_tree().quit(1)
		return
	else:
		print("SUCCESS: Tutorial mission unlocked.")

	# 4. Test 2D Hacking Terminal Logic
	print("TEST: Verifying 2D Hacking Terminal logic...")
	var terminal_script = load("res://scripts/objects/HackingTerminal.gd")
	if not terminal_script:
		print("FAIL: HackingTerminal script not found!")
		get_tree().quit(1)
		return
		
	var terminal = Node2D.new()
	terminal.set_script(terminal_script)
	terminal.is_main_objective = true
	terminal.money_reward = 1000
	
	# Simulate success
	GameManager.main_loot_collected = false
	terminal._on_hacking_success(true)
	
	if not GameManager.main_loot_collected:
		print("FAIL: Terminal did not set main_loot_collected to true!")
		get_tree().quit(1)
		return
	else:
		print("SUCCESS: Terminal correctly updated main_loot_collected.")

	# 5. Test Mission MelTech Setup
	print("TEST: Verifying MelTech mission data...")
	var meltech = load("res://resources/Missions/Mission_MelTech.tres")
	if meltech:
		print("SUCCESS: MelTech mission loaded. Objective: ", meltech.objective_item)
	else:
		print("FAIL: MelTech mission resource not found!")
		get_tree().quit(1)
		return

	print("--- ALL TESTS PASSED ---")
	print("Waiting 5s before exit to allow log capture...")
	await get_tree().create_timer(5.0).timeout
	get_tree().quit()
