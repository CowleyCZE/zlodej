@tool
extends EditorScript

func _run():
	print("--- DEBUG START: Story System ---")
	
	# 1. Získání reference na StoryManager (Autoload)
	# V EditorScriptu autoloady neběží automaticky, musíme je simulovat nebo k nim přistoupit přes EditorInterface
	# Ale pro jednoduchost si vytvoříme novou instanci pro izolovaný test
	
	var story_manager = load("res://scripts/autoload/StoryManager.gd").new()
	var game_manager = load("res://scripts/autoload/GameManager.gd").new()
	
	# Mock EventBus (protože ten je taky autoload)
	# Pro tento test stačí, když StoryManager nebude padat na volání EventBusu
	# To je trochu složité bez kompletního prostředí.
	
	print("Instancuji StoryManager...")
	
	# Manuálně nastavíme data
	story_manager.active_events = []
	var evt = load("res://scripts/resources/StoryEvent.gd").new()
	evt.event_id = "test_call"
	evt.character_name = "Test Honza"
	evt.dialogue_text = "Test message"
	evt.is_phone_call = true
	evt.trigger_delay_seconds = 0.0 # Hned
	story_manager.active_events.append(evt)
	
	print("Event fronta připravena. Spouštím check...")
	
	# Simulace kontroly
	if story_manager._can_trigger(evt):
		print("✅ Event 'test_call' splňuje podmínky.")
		# Simulace triggeru
		print("Simuluji trigger...")
		# Zde nemůžeme volat _trigger_event naplno, protože chybí PhoneUI a EventBus
		# Ale můžeme ověřit logiku
		if evt.is_phone_call:
			print("✅ Event je identifikován jako telefonát.")
	else:
		print("❌ Event 'test_call' nesplňuje podmínky!")

	print("--- DEBUG END ---")
