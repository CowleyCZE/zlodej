# SaveManager.gd (Autoload)
extends Node

const SAVE_PATH = "user://savegame.dat"
const SAVE_VERSION = 3

var disable_saving: bool = false # For testing purposes

func _ready() -> void:
	# Connect to critical signals for auto-saving
	EventBus.mission_completed.connect(func(_id): save_game())
	EventBus.character_hired.connect(func(_char): save_game())
	EventBus.inventory_changed.connect(save_game)
	EventBus.wallet_changed.connect(func(_amount): save_game())

func save_exists() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func save_game():
	if disable_saving:
		print("Save disabled during testing.")
		return

	var save_data = {
		"version": SAVE_VERSION,
		"player": {
			"name": GameManager.player_name,
			"reputation": GameManager.reputation,
			"heat_levels": GameManager.heat_levels
		},
		"world": {
			"time": TimeManager.serialize(),
			"weather": WeatherManager.serialize()
		},
		"economy": {
			"wallet": EconomyManager.wallet
		},
		"inventory": _serialize_inventory(),
		"progress": {
			"completed_missions": ProgressManager.completed_missions,
			"unlocked_missions": ProgressManager.unlocked_missions
		},
		"adventure": {
			"hired_character_paths": _get_hired_character_paths()
		},
		"story": StoryManager.serialize(),
		"narrative": NarrativeManager.serialize(),
		"mission_intel": _serialize_mission_intel()
	}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(save_data, true)
		file.close()
		print("Hra úspěšně uložena.")

func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		print("Uložená hra nenalezena.")
		return
		
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return
		
	var save_data = file.get_var(true)
	file.close()
	
	# Migration logic
	if save_data.get("version", 0) < SAVE_VERSION:
		_migrate_save(save_data)
	
	_restore_game_state(save_data)
	print("Hra úspěšně načtena.")

func _serialize_inventory() -> Array:
	var serialized = []
	for entry in InventoryManager.items:
		serialized.append({
			"id": entry.item.id,
			"quantity": entry.quantity
		})
	return serialized

func _get_hired_character_paths() -> Array[String]:
	var paths: Array[String] = []
	for character in AdventureManager.hired_characters:
		if character.resource_path != "":
			paths.append(character.resource_path)
	return paths

func _serialize_mission_intel() -> Dictionary:
	var intel_data = {}
	for mission in MissionDB.missions:
		intel_data[mission.mission_id] = {
			"is_address_known": mission.is_address_known,
			"intel_flags": mission.intel_flags,
			"known_facts": mission.known_facts,
			"discovered_entry_points": mission.discovered_entry_points
		}
	return intel_data

func _migrate_save(_save_data):
	# Placeholder for future migrations
	pass

func _restore_game_state(save_data):
	# 1. Player Info
	if save_data.has("player"):
		var p = save_data["player"]
		GameManager.player_name = p.get("name", "Thief")
		GameManager.reputation = p.get("reputation", 0)
		GameManager.heat_levels = p.get("heat_levels", {"melnik": 0.0, "prague": 0.0})
	
	# 2. World State
	if save_data.has("world"):
		var w = save_data["world"]
		if w.has("time"): TimeManager.deserialize(w["time"])
		if w.has("weather"): WeatherManager.deserialize(w["weather"])
	
	# 3. Economy
	if save_data.has("economy"):
		EconomyManager.wallet = save_data["economy"].get("wallet", 1000)
	
	# 3. Inventory
	if save_data.has("inventory"):
		InventoryManager.clear_inventory()
		for entry in save_data["inventory"]:
			var item_id = entry["id"]
			var quantity = entry["quantity"]
			if EconomyManager.item_db.has(item_id):
				InventoryManager.load_item_direct(EconomyManager.item_db[item_id], quantity)
		InventoryManager.finalize_load()
	
	# 4. Progress
	if save_data.has("progress"):
		ProgressManager.completed_missions = save_data["progress"].get("completed_missions", [])
		ProgressManager.unlocked_missions = save_data["progress"].get("unlocked_missions", [])
	
	# 5. Adventure (Characters)
	if save_data.has("adventure"):
		AdventureManager.hired_characters.clear()
		for path in save_data["adventure"].get("hired_character_paths", []):
			if ResourceLoader.exists(path):
				var char_data = load(path)
				if char_data is CharacterData:
					AdventureManager.hired_characters.append(char_data)
	
	# 6. Story
	if save_data.has("story"):
		StoryManager.deserialize(save_data["story"])
	
	# 7. Narrative (Loop)
	if save_data.has("narrative"):
		NarrativeManager.deserialize(save_data["narrative"])
	
	# 8. Mission Intel
	if save_data.has("mission_intel"):
		var intel_map = save_data["mission_intel"]
		for mission in MissionDB.missions:
			if intel_map.has(mission.mission_id):
				var m_intel = intel_map[mission.mission_id]
				mission.is_address_known = m_intel.get("is_address_known", false)
				mission.intel_flags = m_intel.get("intel_flags", mission.intel_flags.duplicate())
				mission.known_facts = m_intel.get("known_facts", {})
				mission.discovered_entry_points = m_intel.get("discovered_entry_points", [])
