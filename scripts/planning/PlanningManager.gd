class_name PlanningManager
extends Node

# References
var ghost_controller: GhostRunController
var current_plan: PlanningData

# State
var selected_character_index: int = 0
var team: Array[CharacterData] = []

signal character_selected(character: CharacterData)
signal plan_updated # Emit when any change happens to the plan

func _ready() -> void:
	# Initialize controller
	ghost_controller = GhostRunController.new()
	ghost_controller.name = "GhostRunController"
	add_child(ghost_controller)
	
	# Listen to events
	EventBus.planning_activated.connect(_on_planning_activated)

func _on_planning_activated(mission: MissionData) -> void:
	print("Planning Phase Started for mission: ", mission.name)
	current_plan = PlanningData.new()
	current_plan.mission_id = mission.mission_id
	
	# Load team from AdventureManager (Ensure typed copy)
	team.clear()
	for char_data in AdventureManager.hired_characters:
		team.append(char_data)
	
	if team.is_empty():
		push_warning("Warning: No team members hired! Adding player as fallback.")
		var fallback_char = CharacterData.new()
		fallback_char.name = GameManager.player_name if GameManager.player_name != "" else "Thief"
		# Give fallback char some generic stats/items for testing
		fallback_char.add_item("lockpick") 
		team.append(fallback_char)
	
	# Initialize plans for all team members
	for member in team:
		current_plan.get_or_create_plan_for(member)
	
	select_character(0)

func select_character(index: int) -> void:
	if index >= 0 and index < team.size():
		selected_character_index = index
		var char_data = team[index]
		character_selected.emit(char_data)
		print("Planning: Selected character ", char_data.name)

# ... (middle) ...

func start_recording_current() -> void:
	if selected_character_index >= 0 and selected_character_index < team.size():
		var char_data = team[selected_character_index]
		ghost_controller.start_recording(char_data)

func commit_current_recording() -> void:
	ghost_controller.stop_recording(true)
	# Conversion: Recording to Waypoints
	if selected_character_index >= 0 and selected_character_index < team.size():
		_convert_recording_to_waypoints(team[selected_character_index])
		plan_updated.emit()

func discard_current_recording() -> void:
	ghost_controller.stop_recording(false)

func _convert_recording_to_waypoints(char_data: CharacterData) -> void:
	var raw_track = ghost_controller.recorded_tracks.get(char_data.name, [])
	if raw_track.is_empty():
		return
		
	var plan = current_plan.get_or_create_plan_for(char_data)
	plan.waypoints.clear()
	plan.actions.clear()
	
	var last_was_interact = false
	
	# Downsample recording to waypoints (simple optimization)
	for i in range(raw_track.size()):
		var frame = raw_track[i]
		
		# 1. Waypoints (keep downsampled)
		if i % 10 == 0: 
			var wp = PlanningData.TimelineWaypoint.new()
			wp.time = frame.time
			wp.position = frame.pos
			wp.speed = 1.0 
			plan.waypoints.append(wp)
		
		# 2. Action Extraction (Exact timing)
		var is_interact = frame.actions.get("interact", false)
		if is_interact and not last_was_interact:
			# Rising Edge -> New Action
			var new_action = PlanningData.TimelineAction.new()
			new_action.time = frame.time
			new_action.type = "INTERACT"
			new_action.target_id = frame.actions.get("target_id", "")
			new_action.duration = 1.0 # Base duration
			
			# Add to plan
			plan.actions.append(new_action)
			print("Extracted Action: INTERACT at ", frame.time)
			
		last_was_interact = is_interact
		
	# Sort actions just in case (though linear scan produces sorted)
	plan.actions.sort_custom(func(a, b): return a.time < b.time)

func get_final_plan() -> PlanningData:
	return current_plan
