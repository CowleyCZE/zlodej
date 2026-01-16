extends Node

enum State {MENU, ADVENTURE, HIDEOUT, PLANNING, ACTION, RESULTS}

var current_state: State = State.MENU
var player_name: String = ""
var current_mission: Resource = null # Using Resource to avoid cyclic/cache issues with MissionData class_name

# Global Stats (Persistence)
var reputation: int = 0:
	set(value):
		reputation = value
		EventBus.reputation_changed.emit(reputation)

var heat_levels: Dictionary = {
	"melnik": 0.0,
	"prague": 0.0
}

# Session State
var current_level_path: String = "res://scenes/levels/WorldMap_2D.tscn"
var current_mission_loot: int = 0
var main_loot_collected: bool = false

var last_mission_results: Dictionary = {
	"success": false,
	"loot_collected": 0,
	"guards_stunned": 0,
	"guards_killed": 0,
	"times_spotted": 0,
	"team_members": []
}

# Signal wrappers (EventBus should be primary, but direct access helps for simple state checks)
signal state_changed(new_state: State)

func _ready() -> void:
	# Default initialization
	current_state = State.MENU
	print("GameManager initialized. State: MENU")

func change_state(new_state: State) -> void:
	if current_state == new_state:
		return
		
	var old_state = current_state
	current_state = new_state
	state_changed.emit(new_state)
	
	print("State changed: ", State.keys()[old_state], " -> ", State.keys()[new_state])
	
	# Logic handled by Game.gd via signal connection

func add_heat(amount: float, region: String = "melnik") -> void:
	if heat_levels.has(region):
		heat_levels[region] = clamp(heat_levels[region] + amount, 0.0, 100.0)
		EventBus.heat_level_changed.emit(heat_levels[region])
		print("Heat in ", region, " changed by ", amount, ". New level: ", heat_levels[region])

func add_reputation(amount: int) -> void:
	reputation += amount
	print("Reputation changed by ", amount, ". New value: ", reputation)

func set_player_name(new_name: String) -> void:
	player_name = new_name
	SaveManager.save_game() # Auto-save on name set

func set_current_level(path: String) -> void:
	current_level_path = path
	current_mission_loot = 0
	main_loot_collected = false
	print("Current level set to: ", path)