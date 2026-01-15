# IntelManager.gd (Autoload)
extends Node

signal intel_updated(mission_id: String, total_intel: float)

const INTEL_COSTS = {
	"physical_reconnaissance": 0,
	"buy_floorplans": 2000,
	"insider_conversation": 1000,
	"hacking": 500
}

func gather_intel(mission: MissionData, method: String) -> bool:
	if not mission:
		printerr("IntelManager: Pokus o sběr informací pro neexistující misi.")
		return false
	
	var cost = INTEL_COSTS.get(method, 0)
	if GameManager.money < cost:
		print("SYSTÉM: Nedostatek peněz na sběr informací (potřeba ", cost, " CZK).")
		return false
		
	GameManager.money -= cost
	EventBus.money_changed.emit(GameManager.money)
	
	var intel_gained = 0.0
	var target_category = ""
	
	match method:
		"physical_reconnaissance":
			intel_gained = randf_range(0.05, 0.15)
			target_category = mission.intel_categories.keys().pick_random()
		"buy_floorplans":
			intel_gained = 0.20
			target_category = "architecture"
		"insider_conversation":
			intel_gained = 0.15
			target_category = "guard_patrols"
		"hacking":
			intel_gained = 0.20
			target_category = "security_systems"
			
	if mission.intel_categories.has(target_category):
		mission.intel_categories[target_category] = clamp(mission.intel_categories[target_category] + intel_gained, 0.0, 1.0)
		print("SYSTÉM: Získáno ", int(intel_gained * 100), "% informací v kategorii '", target_category, "' pro misi ", mission.name)
	
	var total_intel = get_total_intel_percentage(mission)
	intel_updated.emit(mission.mission_id, total_intel)
	
	if total_intel >= 50.0:
		print("SYSTÉM: Dosazeno 50% informací. Planning Mode je nyní dostupný pro tuto misi.")
		
	return true

func get_total_intel_percentage(mission: MissionData) -> float:
	if not mission: return 0.0
	
	var total = 0.0
	for key in mission.intel_categories:
		total += mission.intel_categories[key]
	
	return (total / mission.intel_categories.size()) * 100.0

func get_intel_status(mission: MissionData) -> String:
	if not mission: return "Žádná mise"
	return "Průzkum: " + str(int(get_total_intel_percentage(mission))) + "%"
