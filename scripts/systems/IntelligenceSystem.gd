# IntelligenceSystem.gd (Autoload)
extends Node

signal intel_updated(mission_id: String, category: String)

func _ready():
	pass

func gather_intel(mission: MissionData, category: String, _amount: float = 0.20):
	if mission.intel_flags.has(category):
		if not mission.intel_flags[category]:
			mission.intel_flags[category] = true
			intel_updated.emit(mission.mission_id, category)
			print("INTEL: Discovered ", category, " for ", mission.name)
			
			# Logic: If we have architecture, we might reveal entry points
			if category == "architecture":
				_auto_discover_entry_points(mission)
				
			SaveManager.save_game()

func buy_intel(mission: MissionData, method: String) -> bool:
	var cost = 0
	var category = ""
	
	match method:
		"buy_floorplans":
			cost = 2000
			category = "architecture"
		"bribe_guard":
			cost = 1000
			category = "patrols"
		"hacker_tip":
			cost = 3000
			category = "security"
			
	if EconomyManager.spend_money(cost):
		gather_intel(mission, category)
		return true
	return false

func _auto_discover_entry_points(mission: MissionData):
	# Placeholder: In a real game, this would read from the level file
	if mission.mission_id == "mission_meltech_01":
		mission.discovered_entry_points.append("Zadní vchod")
		mission.is_address_known = true
