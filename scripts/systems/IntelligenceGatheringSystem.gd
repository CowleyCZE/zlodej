class_name IntelligenceGatheringSystem
extends Node

# Centralizovaná logika pro získávání informací (Intel)
# Řeší náklady (Peníze) a následky (Heat)

# Ceny a rizika pro jednotlivé kategorie
const INTEL_COSTS = {
	"architecture": 2000,
	"patrols": 1500,
	"security": 0,    # Hacking (zdarma, ale vysoký heat)
	"treasure": 500,  # Úplatek informátorovi
	"routes": 0       # Fyzický průzkum (zdarma, riskantní)
}

const INTEL_HEAT = {
	"architecture": 2.0,   # Nákup plánů je podezřelý, ale málo
	"patrols": 5.0,        # Kontaktování stráží
	"security": 15.0,      # Průnik do sítě
	"treasure": 5.0,       # Ptaní se po městě
	"routes": 10.0         # Slídění kolem budovy
}

static func get_cost(category: String) -> int:
	return INTEL_COSTS.get(category, 1000)

static func get_heat_risk(category: String) -> float:
	return INTEL_HEAT.get(category, 5.0)

static func try_gather_intel(mission: MissionData, category: String) -> bool:
	if mission.intel_flags.get(category, false):
		return true # Už máme
		
	var cost = get_cost(category)
	var heat = get_heat_risk(category)
	
	if EconomyManager.wallet >= cost:
		# Transakce
		if cost > 0:
			EconomyManager.wallet -= cost
		
		# Následek
		GameManager.add_heat(heat, mission.region_id if mission.region_id else "melnik")
		
		# Zisk
		mission.intel_flags[category] = true
		
		SaveManager.save_game()
		print("Intel acquired: ", category, " | Cost: ", cost, " | Heat +", heat)
		return true
	else:
		print("Not enough money for intel: ", category)
		return false
