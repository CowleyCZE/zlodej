# res://Data/MissionLoader.gd
extends Node
class_name MissionLoader

var missions: Array[MissionData] = []

func _ready() -> void:
	_load_missions()

func _load_missions() -> void:
	# 1. Load Legacy JSON
	var file := FileAccess.open("res://data/missions.json", FileAccess.READ)
	if file:
		var data: Dictionary = JSON.parse_string(file.get_as_text())
		file.close()
		if data.has("missions"):
			for m in data["missions"]:
				var mission := MissionData.new()
				mission.mission_id = m["id"]
				mission.region_id = m.get("region_id", "")
				mission.name = m["name"]
				mission.description = m["description"]
				mission.difficulty = m.get("difficulty", 1.0)
				mission.min_reputation = m.get("min_reputation", 0)
				mission.base_reward = m.get("reward", 0.0)
				missions.append(mission)
	
	# 2. Load New Resources (.tres)
	_load_resources_from_dir("res://resources/Missions/")

func _load_resources_from_dir(path: String) -> void:
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir() and (file_name.ends_with(".tres") or file_name.ends_with(".remap")):
				# .remap is for exported projects, we strip it
				var load_path = path + file_name.replace(".remap", "")
				var res = load(load_path)
				if res is MissionData:
					# Check for duplicates
					var exists = false
					for m in missions:
						if m.mission_id == res.mission_id:
							exists = true; break
					if not exists:
						missions.append(res)
						print("Loaded mission resource: ", res.mission_id)
			file_name = dir.get_next()

func get_missions_for_region(region_id: String) -> Array[MissionData]:
	return missions.filter(func(m: MissionData) -> bool:
		return m.region_id == region_id)
