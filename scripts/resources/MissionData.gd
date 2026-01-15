class_name MissionData
extends Resource

# Identifikace
@export var mission_id: String
@export var name: String
@export_multiline var description: String
@export_multiline var briefing: String

# Lokace a Meta
@export var region_id: String
@export var target_location: String  # scene path or ID
@export var difficulty: int = 1 # 1-5 hvězd
@export var min_reputation: int = 0

# Cíl
@export var objective_type: String  # "steal_money", "steal_item", "collect_data"
@export var objective_item: String
@export var base_reward: int = 20000
@export var reputation_gain: int = 20

# Zabezpečení (Intel)
@export var guard_count: int = 2
@export var camera_count: int = 2
@export var has_alarm: bool = true

# Requirement 1: Sbírání informací a tipů
@export var address: String = "Neznámá lokace" # Unlocked via gathering
@export var is_address_known: bool = false

# Konkrétní objevená fakta (nahrazuje/rozšiřuje intel_flags)
# Klíč: ID faktu (např. "back_door_open"), Hodnota: Popis (např. "Zadní vchod bývá odemčený")
@export var known_facts: Dictionary = {}

# Objevené vstupy do objektu
@export var discovered_entry_points: Array[String] = []

# Intel Categories (Each approx 20%)
@export var intel_flags: Dictionary = {
	"architecture": false, # Building Layout
	"patrols": false,      # Guard Routines
	"security": false,     # Camera positions
	"treasure": false,     # Target location
	"routes": false        # Entry points
}

func get_total_intel_percentage() -> float:
	var total: float = 0.0
	
	for key in intel_flags:
		if intel_flags[key]:
			total += 0.20 # 20% per category
		
	return total

# Požadavky pro Planning
@export var required_tools: Array[String]
@export var max_team_size: int = 4
@export var time_limit_seconds: float = 600.0
