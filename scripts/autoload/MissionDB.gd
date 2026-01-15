extends Node

# MissionDB - "Databáze" misí ve hře
# V reálné hře by se to načítalo z JSON/XML souboru.

var missions: Dictionary = {}

func _ready():
	_build_mission_database()

func _build_mission_database():
	# Mise 1: Tutorial
	var miss001 = MissionData.new()
	miss001.mission_id = "MISS001"
	miss001.name = "Malý zkoušební lup"
	miss001.description = "Ukrást digitální disk z kanceláře MelTech s.r.o."
	miss001.briefing = "Honza ti zavolá: 'Mám pro tebe první robotu...'"
	miss001.target_location = "MelTech Office"
	miss001.objective_type = "steal_item"
	miss001.objective_item = "Digitalni Disk"
	miss001.guard_count = 0
	miss001.camera_count = 1
	miss001.alarm_system = false
	miss001.base_reward = 5000.0
	miss001.reputation_gain = 20
	miss001.difficulty_stars = 1
	missions["MISS001"] = miss001
	
	# Mise 2: Komerční banka
	var miss002 = MissionData.new()
	miss002.mission_id = "MISS002"
	miss002.name = "Komerční Banka Mělník"
	miss002.description = "Ukrást 200,000 CZK z trezoru."
	miss002.target_location = "Komercni Banka"
	miss002.objective_type = "steal_money"
	miss002.objective_value = 200000.0
	miss002.guard_count = 2
	miss002.camera_count = 4
	miss002.alarm_system = true
	miss002.base_reward = 20000.0
	miss002.reputation_gain = 30
	miss002.difficulty_stars = 2
	missions["MISS002"] = miss002

	# Zde by se přidaly další mise...
