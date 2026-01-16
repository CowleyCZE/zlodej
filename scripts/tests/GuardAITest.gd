extends Node

func _ready():
	print("--- STARTING GUARD AI ADVANCED TEST (FIXED) ---")
	GameManager.current_state = GameManager.State.ACTION
	
	var guard_scene = load("res://scenes/objects/Guard.tscn")
	var player_scene = load("res://scenes/agents/PlayerAgent.tscn")
	
	var guard = guard_scene.instantiate()
	var player = player_scene.instantiate()
	
	add_child(guard)
	add_child(player)
	
	guard.global_position = Vector2(500, 500)
	guard.global_rotation = 0 # Looking right
	
	print("- Čekám na inicializaci fyziky (3 framy)...")
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	
	# --- 1. Test vzdálenostní detekce ---
	print("TEST 1: Vzdálenostní detekce (daleko)...")
	player.global_position = guard.global_position + Vector2(150, 0) 
	
	# Monitor overlap
	await get_tree().create_timer(1.0).timeout
	var slow_alert = guard.alert_meter
	print("- Alert meter po 1s v dálce: ", slow_alert)
	
	print("TEST 2: Vzdálenostní detekce (blízko)...")
	guard.alert_meter = 0
	player.global_position = guard.global_position + Vector2(40, 0)
	await get_tree().create_timer(1.0).timeout
	var fast_alert = guard.alert_meter
	print("- Alert meter po 1s blízko: ", fast_alert)
	
	if fast_alert <= slow_alert or fast_alert == 0:
		print("FAIL: Detekce neprobíhá nebo vzdálenostní modifikátor nefunguje!")
	else:
		print("SUCCESS: Vzdálenostní modifikátor potvrzen.")

	# --- 3. Test Zpozornění (Suspicious) ---
	print("TEST 3: Krátké zahlédnutí (Zpozornění)...")
	guard.alert_meter = 0
	guard.set_ai_state(guard.AIState.PATROL)
	
	# Hráč se ukáže na chvíli (dostatečně na to, aby meter > 20)
	player.global_position = guard.global_position + Vector2(60, 0)
	# Detection speed je 50. Vzdálenost 60/200 -> dist_factor ~0.7. 
	# 50 * 0.7 = 35 pts/sec. Potřebujeme 20 pts -> cca 0.6 sec.
	await get_tree().create_timer(0.7).timeout
	player.global_position = Vector2(-1000, -1000) # Zmizí
	
	await get_tree().create_timer(0.2).timeout
	print("- Stav stráže po zahlédnutí: ", guard.AIState.keys()[guard.current_ai_state])
	if guard.current_ai_state == 1: # SUSPICIOUS
		print("SUCCESS: Strážce zpozorněl a zastavil.")
	else:
		print("FAIL: Strážce nepřešel do stavu SUSPICIOUS.")

	# --- 4. Test Prohledávání (Search) ---
	print("TEST 4: Prohledávání místa (Search)...")
	# Pustíme čas, aby strážce přešel ze SUSPICIOUS do SEARCH (suspicion_timer = 2.0s)
	print("- Čekám na vypršení suspicion_timer (2s)...")
	await get_tree().create_timer(2.5).timeout
	
	print("- Aktuální stav: ", guard.AIState.keys()[guard.current_ai_state])
	if guard.current_ai_state == 2: # SEARCH
		# TELEPORT GUARD TO TARGET (Simulate arrival, since navigation is missing in test scene)
		guard.global_position = Vector2(560, 500)
		print("- Teleportuji strážce k cíli (simulace chůze)...")
		
		var initial_rot = guard.rotation
		print("- Pozice stráže: ", guard.global_position)
		await get_tree().create_timer(1.0).timeout
		print("- Rotace před: ", initial_rot, " po: ", guard.rotation)
		if abs(guard.rotation - initial_rot) > 0.05:
			print("SUCCESS: Strážce aktivně prohledává (kroutí hlavou).")
		else:
			print("FAIL: Strážce na místě stojí staticky.")
	else:
		print("FAIL: Strážce nepřešel do stavu SEARCH.")

	print("--- GUARD AI TEST COMPLETED ---")
	while true:
		await get_tree().create_timer(1.0).timeout
