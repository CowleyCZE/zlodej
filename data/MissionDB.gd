extends Node

# Databáze misí a pomocné funkce pro jejich správu
# Slouží jako centrální repozitář všech definic misí

var missions: Dictionary = {} # mission_id -> MissionData

func _ready() -> void:
	_initialize_missions()

func _initialize_missions() -> void:
	# Podle LDD - Mission 1: Tutorial
	var m1 = MissionData.new()
	m1.mission_id = "MISS001"
	m1.name = "Malý zkoušební lup"
	m1.description = "Honza pro tebe má první práci. Jednoduchá vloupačka do kanceláře MelTech s.r.o. Získej disk s daty."
	m1.briefing = "Hej, slyšel jsem, že jseš v Mělníku. Mám pro tebe první robotu - taková ta jednoducha. Když se osvědčíš, máme spousty peněz na tebe."
	m1.target_location = "meltech_office"
	m1.scene_path = "res://scenes/levels/Level_Warehouse_Small.tscn" # Placeholder scéna
	m1.objective_type = "steal_item"
	m1.objective_item = "Digital Disk"
	m1.objective_value = 5000.0
	m1.base_reward = 5000.0
	m1.reputation_gain = 20
	m1.difficulty_stars = 1
	m1.guard_count = 0
	m1.camera_count = 1
	m1.alarm_system = false
	m1.intel_categories = {
		"architecture": 0.5,
		"guard_patrols": 1.0, # Žádní strážci
		"security_systems": 0.2,
		"treasure_location": 1.0,
		"alternate_routes": 0.0
	}
	missions[m1.mission_id] = m1
	
	# Podle LDD - Mission 2: Komercní Banka
	var m2 = MissionData.new()
	m2.mission_id = "MISS002"
	m2.name = "Komerční Banka Mělník"
	m2.description = "Místní pobočka v centru. Trezor obsahuje hotovost."
	m2.briefing = "Tohle už není hra. Máme tip na hotovost v bance. Budeš potřebovat tým."
	m2.target_location = "bank_melnik"
	m2.scene_path = "res://scenes/levels/WorldMap_City.tscn" # Placeholder
	m2.objective_type = "steal_money"
	m2.objective_value = 200000.0
	m2.base_reward = 20000.0
	m2.reputation_gain = 30
	m2.difficulty_stars = 2
	m2.guard_count = 2
	m2.camera_count = 4
	m2.alarm_system = true
	m2.is_available = false # Odemkne se po tutorialu
	missions[m2.mission_id] = m2

func get_mission(id: String) -> MissionData:
	if missions.has(id):
		return missions[id]
	return null

func get_available_missions() -> Array[MissionData]:
	var available: Array[MissionData] = []
	for m in missions.values():
		if m.is_available:
			available.append(m)
	return available

func complete_mission(id: String):
	if missions.has(id):
		var mission = missions[id]
		mission.is_completed = true
		
		# Logika odemykání dalších misí
		if id == "MISS001":
			if missions.has("MISS002"):
				missions["MISS002"].is_available = true
				print("Mise MISS002 odemčena!")
