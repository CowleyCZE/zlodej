extends Node

func _ready():
	print("--- STARTING GHOST RUN TEST ---")
	
	# 1. Setup Mock Team
	var char1 = CharacterData.new()
	char1.name = "Alfa"
	
	var char2 = CharacterData.new()
	char2.name = "Beta"
	
	var char3 = CharacterData.new()
	char3.name = "Gama"
	
	# Mocking AdventureManager since it's Autoload
	AdventureManager.hired_characters = [char1, char2, char3]
	print("Mock Team created: ", AdventureManager.hired_characters.size())
	
	# 2. Load Planning Mode
	var plan_scene = load("res://scenes/core/PlanningMode.tscn")
	var planning_mode = plan_scene.instantiate()
	add_child(planning_mode)
	
	# 3. Simulate Mission Start
	await get_tree().process_frame
	
	var mock_mission = MissionData.new()
	mock_mission.mission_id = "TEST_MISSION"
	mock_mission.target_location = "res://scenes/levels/Level_Tutorial.tscn"
	
	print("Emitting planning_activated signal...")
	EventBus.planning_activated.emit(mock_mission)
