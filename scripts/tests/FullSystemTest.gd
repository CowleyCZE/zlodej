extends Node

func _ready():
	# Počkáme, až se vše usadí
	await get_tree().process_frame
	
	# Aktivujeme testovací režim (bez ukládání na disk)
	if SaveManager:
		SaveManager.disable_saving = true
	
	# Timeout pojistka (20 sekund)
	get_tree().create_timer(20.0).timeout.connect(func():
		print("\n[CRITICAL ERROR] TEST TIMEOUT - Některý test zamrznul nebo trvá příliš dlouho.")
		get_tree().quit(1)
	)
	
	print("--- SPUŠTĚNÍ SYSTEM VERIFICATION TEST ---")
	var failures = 0
	var tests = 0
	
	# 1. TEST AUDIO RESOURCES
	tests += 1
	print("[TEST 1] Audio Library Integrity...")
	var audio = AudioManager
	if not audio:
		print("  [FAIL] AudioManager autoload not found!")
		failures += 1
	else:
		var missing_files = []
		for key in audio.SFX_LIBRARY:
			var path = audio.SFX_LIBRARY[key]
			if not FileAccess.file_exists(path):
				missing_files.append(path)
		
		if missing_files.size() > 0:
			print("  [FAIL] Chybějící audio soubory:")
			for f in missing_files: print("    - " + f)
			failures += 1
		else:
			print("  [PASS] Všechny audio soubory v knihovně existují.")

	# 2. TEST MISSION RESOURCES
	tests += 1
	print("[TEST 2] Mission Resources Loading...")
	var mission_path = "res://resources/Missions/Mission_Tutorial.tres"
	if FileAccess.file_exists(mission_path):
		var mission = load(mission_path)
		if mission and mission is Resource: 
			print("  [PASS] Mission_Tutorial načtena úspěšně.")
		else:
			print("  [FAIL] Mission_Tutorial nelze načíst nebo špatný typ.")
			failures += 1
	else:
		print("  [FAIL] Soubor mise neexistuje: " + mission_path)
		failures += 1

	# 3. TEST ECONOMY
	tests += 1
	print("[TEST 3] Economy Manager Logic...")
	if EconomyManager:
		var initial = EconomyManager.wallet
		EconomyManager.add_money(100)
		if EconomyManager.wallet == initial + 100:
			if EconomyManager.spend_money(50):
				if EconomyManager.wallet == initial + 50:
					print("  [PASS] Transakce fungují.")
				else:
					print("  [FAIL] Chyba při odečítání peněz.")
					failures += 1
			else:
				print("  [FAIL] spend_money(50) vrátilo false, ačkoliv je dost peněz.")
				failures += 1
		else:
			print("  [FAIL] add_money nefunguje.")
			failures += 1
		EconomyManager.wallet = initial
	else:
		print("  [FAIL] EconomyManager autoload nenalezen.")
		failures += 1

	# 4. TEST WEATHER SYSTEM
	tests += 1
	print("[TEST 4] Weather System Signals...")
	if WeatherManager:
		# Test signal emission (using array for reference capture)
		var signal_captured = [false]
		var test_fn = func(_w): signal_captured[0] = true
		WeatherManager.weather_changed.connect(test_fn)
		
		WeatherManager.current_weather = WeatherManager.WeatherType.RAIN
		await get_tree().process_frame
		
		if signal_captured[0] and WeatherManager.current_weather == WeatherManager.WeatherType.RAIN:
			print("  [PASS] WeatherManager emituje signály a mění stav.")
		else:
			print("  [FAIL] WeatherManager signál nebyl zachycen.")
			failures += 1
			
		WeatherManager.weather_changed.disconnect(test_fn)
	else:
		print("  [FAIL] WeatherManager autoload nenalezen.")
		failures += 1
		
	# 5. TEST INTERACTION LOGIC (Hacking -> Door)
	tests += 1
	print("[TEST 5] MelTech Interaction Logic (Hacking -> Door)...")
	# Instantiate Door and Terminal manually to test logic without full scene
	var door_scene = load("res://scenes/objects/Door.tscn")
	var term_scene = load("res://scenes/objects/HackingTerminal.tscn")
	
	if door_scene and term_scene:
		var door = door_scene.instantiate()
		var term = term_scene.instantiate()
		add_child(door)
		add_child(term)
		
		# Setup Connection
		var test_group = "test_group_123"
		door.remote_group_id = test_group
		door.is_locked = true
		term.unlocks_group_id = test_group
		
		# Simulate Hack Success
		term._on_hacking_success(true)
		
		# Allow EventBus to process signals
		await get_tree().process_frame 
		await get_tree().process_frame 
		
		if not door.is_locked and door.required_tool == "":
			print("  [PASS] Terminál úspěšně odemkl dveře přes EventBus.")
		else:
			print("  [FAIL] Dveře zůstaly zamčené po hacknutí.")
			print("    Door Locked: ", door.is_locked)
			print("    Remote Group: ", door.remote_group_id)
			failures += 1
			
		door.queue_free()
		term.queue_free()
	else:
		print("  [FAIL] Nelze načíst scény Door nebo HackingTerminal.")
		failures += 1

	# 6. TEST LEVEL TUTORIAL SANITY
	tests += 1
	print("[TEST 6] Level Tutorial Sanity Check...")
	var level_scene = load("res://scenes/levels/Level_Tutorial.tscn")
	if level_scene:
		var level = level_scene.instantiate()
		# Add to tree to run _ready logic (where guard parameters are tweaked)
		add_child(level) 
		await get_tree().process_frame
		
		var guard = level.get_node_or_null("Guards/Guard1")
		if guard:
			# Check if nerf was applied
			if guard.detection_speed < 40.0: # Should be 25.0
				print("  [PASS] Level Tutorial skript běží a upravil parametry stráže.")
			else:
				print("  [FAIL] Stráž má defaultní (vysokou) detection_speed: ", guard.detection_speed)
				failures += 1
		else:
			print("  [FAIL] Stráž nenalezena v Level_Tutorial.")
			failures += 1
			
		level.queue_free()
	else:
		print("  [FAIL] Level_Tutorial nelze načíst.")
		failures += 1

	print("---------------------------------------")
	print("VÝSLEDEK: %d testů, %d chyb." % [tests, failures])
	
	if failures > 0:
		get_tree().quit(1)
	else:
		# Krátká pauza pro flush logu
		await get_tree().create_timer(0.5).timeout
		get_tree().quit(0)
