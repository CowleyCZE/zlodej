class_name PlanningData
extends Resource

# --- Configuration ---
@export var mission_id: String = ""
@export var timeline_duration: float = 600.0 # 10 minutes

# --- Data Structure ---
# characters: Array[CharacterData]
@export var characters: Array[CharacterData] = []

# character_plans: Dictionary[char_name, CharacterPlan]
@export var character_plans: Dictionary = {}

# --- Inner Classes (Helper Structures) ---

class TimelineWaypoint:
	var position: Vector2
	var time: float
	var speed: float = 1.0 # 1.0 = Walk, 2.0 = Run, 0.5 = Sneak

class TimelineAction:
	var time: float
	var type: String # "MOVE", "WAIT", "INTERACT", "RADIO", "TAKE_LOOT"
	var duration: float
	var target_id: String
	var required_skill: String
	var is_complete: bool = false
	
	# Requirement 4: Tool selection & Synchronization
	var selected_tool_id: String = "" # Specific tool used for this action (e.g. "lockpick_mk2")
	var wait_for_signal: String = "" # Wait until this signal is emitted (e.g. "alarm_disabled")
	var emit_signal_on_complete: String = "" # Emit this signal when done


class CharacterPlan:
	var character: CharacterData
	var waypoints: Array[TimelineWaypoint] = []
	var actions: Array[TimelineAction] = []
	
	func get_position_at_time(time: float) -> Vector2:
		if waypoints.is_empty():
			return Vector2.ZERO
			
		# 1. Check bounds
		if time <= waypoints[0].time:
			return waypoints[0].position
		if time >= waypoints.back().time:
			return waypoints.back().position
			
		# 2. Linear Search for the segment (can be optimized to binary search if needed)
		for i in range(waypoints.size() - 1):
			var current_wp = waypoints[i]
			var next_wp = waypoints[i + 1]
			
			if time >= current_wp.time and time < next_wp.time:
				# Calculate weight (0.0 to 1.0)
				var t_diff = next_wp.time - current_wp.time
				if t_diff <= 0: return current_wp.position
				
				var weight = (time - current_wp.time) / t_diff
				return current_wp.position.lerp(next_wp.position, weight)
				
		return waypoints.back().position

# --- Public API ---

func get_or_create_plan_for(character: CharacterData) -> CharacterPlan:
	if not character_plans.has(character.name):
		var new_plan = CharacterPlan.new()
		new_plan.character = character
		character_plans[character.name] = new_plan
		if not character in characters:
			characters.append(character)
	return character_plans[character.name]

func clear_all():
	characters.clear()
	character_plans.clear()
