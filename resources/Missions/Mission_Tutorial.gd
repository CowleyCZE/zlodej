extends MissionData

func _init():
	mission_id = "mission_tutorial"
	name = "Vloupačka nanečisto"
	description = "Tréninková mise v opuštěném skladu MelTech."
	briefing = "Cíl: Dostaň se dovnitř, seber data z terminálu a zmiz."
	region_id = "melnik_industrial"
	target_location = "res://scenes/levels/Level_Tutorial.tscn" # Cesta k levelu
	difficulty = 1
	min_reputation = 0
	base_reward = 5000
	objective_type = "steal_data"
	guard_count = 1
	camera_count = 1
