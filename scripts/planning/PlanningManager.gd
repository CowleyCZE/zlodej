class_name PlanningManager
extends Node

# References
var ghost_controller: GhostRunController
var current_plan: PlanningData

# State
var selected_character_index: int = 0
var team: Array[CharacterData] = []
var validation_errors: Array = []

signal character_selected(character: CharacterData)
signal plan_updated # Emit when any change happens to the plan
signal plan_validated(errors: Array)

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
	ghost_controller.stop_recording()
	# Conversion: Recording to Waypoints
	if selected_character_index >= 0 and selected_character_index < team.size():
		_convert_recording_to_waypoints(team[selected_character_index])
		plan_updated.emit()

func discard_current_recording() -> void:
	ghost_controller.stop_recording()

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

func assign_tool_to_action(char_data: CharacterData, action_index: int, tool_id: String) -> void:
	var plan = current_plan.get_or_create_plan_for(char_data)
	if action_index >= 0 and action_index < plan.actions.size():
		plan.actions[action_index].selected_tool_id = tool_id
		plan_updated.emit()
		ghost_controller.set_plan(current_plan) # Recalculate if needed

func add_synchronization_wait(char_data: CharacterData, action_index: int, signal_name: String) -> void:
	var plan = current_plan.get_or_create_plan_for(char_data)
	if action_index >= 0 and action_index < plan.actions.size():
		plan.actions[action_index].wait_for_signal = signal_name
		plan_updated.emit()
		ghost_controller.set_plan(current_plan) # Crucial: triggers delay recalculation

func set_action_emit_signal(char_data: CharacterData, action_index: int, signal_name: String) -> void:
	var plan = current_plan.get_or_create_plan_for(char_data)
	if action_index >= 0 and action_index < plan.actions.size():
		plan.actions[action_index].emit_signal_on_complete = signal_name
		plan_updated.emit()
		ghost_controller.set_plan(current_plan)

func remove_action(char_data: CharacterData, action_index: int) -> void:
	var plan = current_plan.get_or_create_plan_for(char_data)
	if action_index >= 0 and action_index < plan.actions.size():
		plan.actions.remove_at(action_index)
		plan_updated.emit()
		ghost_controller.set_plan(current_plan)

func add_wait_action(char_data: CharacterData, time: float, duration: float = 2.0) -> void:
	var plan = current_plan.get_or_create_plan_for(char_data)
	var new_action = PlanningData.TimelineAction.new()
	new_action.time = time
	new_action.type = "WAIT"
	new_action.duration = duration
	
	plan.actions.append(new_action)
	plan.actions.sort_custom(func(a, b): return a.time < b.time)
	
	plan_updated.emit()
	ghost_controller.set_plan(current_plan)
	print("PlanningManager: Added WAIT action for ", char_data.name, " at ", time)

func get_final_plan() -> PlanningData:
	validate_plan()
	# Attach raw tracks for Action Mode execution
	current_plan.set_meta("recorded_tracks", ghost_controller.recorded_tracks.duplicate())
	return current_plan

func validate_plan() -> bool:
	validation_errors.clear()
	_check_collisions()
	# TODO: _check_noise_levels()
	plan_validated.emit(validation_errors)
	return validation_errors.is_empty()

func _check_collisions():
	if not current_plan or current_plan.characters.size() < 2:
		return
		
	var duration = current_plan.timeline_duration
	var step = 0.5 # Check every half second
	
	for t in range(0, int(duration / step)):
		var time = t * step
		
		# Compare every pair of characters
		for i in range(current_plan.characters.size()):
			for j in range(i + 1, current_plan.characters.size()):
				var char1 = current_plan.characters[i]
				var char2 = current_plan.characters[j]
				
				var plan1 = current_plan.get_or_create_plan_for(char1)
				var plan2 = current_plan.get_or_create_plan_for(char2)
				
				var pos1 = plan1.get_position_at_time(time)
				var pos2 = plan2.get_position_at_time(time)
				
				if pos1.distance_to(pos2) < 30.0: # Threshold for collision (pixels)
					validation_errors.append({
						"type": "COLLISION",
						"time": time,
						"chars": [char1.name, char2.name],
						"pos": pos1
					})
					# We found a collision for this pair, skip to next pair or time?
					# For now, collect all major ones
