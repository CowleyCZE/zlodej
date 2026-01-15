extends Node2D

@onready var planning_manager = $PlanningManager
@onready var recording_hud: RecordingHUD = $CanvasLayer/RecordingHUD
@onready var blueprint_view: Node2D = $BlueprintView

var current_level_node: Node2D
var agents: Dictionary = {} # character_name (String) -> PlayerAgent (Node)
var path_visualizer

func _ready():
	# Initialize HUD with Manager reference
	if recording_hud and planning_manager:
		recording_hud.setup(planning_manager)
	
	# Setup Visualizer
	var vis_scene = load("res://scenes/planning/GhostPathVisualizer.tscn")
	if vis_scene:
		path_visualizer = vis_scene.instantiate()
		path_visualizer.setup(planning_manager.ghost_controller)
		blueprint_view.add_child(path_visualizer) 
	
	# Listen for mission start to load level
	EventBus.planning_activated.connect(_on_mission_activated)
	
	# Connect to manager signals
	planning_manager.character_selected.connect(_on_character_selected)
	
	# Connect GhostController update signal to sync ghosts
	planning_manager.ghost_controller.time_changed.connect(_on_time_changed)
	planning_manager.ghost_controller.recording_started.connect(_on_recording_started)
	planning_manager.ghost_controller.action_triggered.connect(_on_action_triggered)
	
	print("Planning Mode Initialized")
	
	# DEBUG: Auto-start tutorial if running standalone
	if OS.is_debug_build() and get_parent() == get_tree().root:
		_debug_start_tutorial.call_deferred()

func _debug_start_tutorial():
	print("DEBUG: Auto-starting Tutorial Mission")
	var mission = load("res://resources/Missions/Mission_Tutorial.tres")
	if mission:
		EventBus.planning_activated.emit(mission)
	else:
		push_error("DEBUG: Could not load Mission_Tutorial.tres")

func _on_action_triggered(char_name: String, type: String, data: Dictionary) -> void:
	if agents.has(char_name):
		agents[char_name].execute_plan_action(type, data)

func _on_recording_started(character: CharacterData) -> void:
	# Reset active agent to start position (time 0)
	# If we have a previous track, we could start from there, but typically we start fresh or from 0
	# For simplicity, we snap to time 0 of the ghost track OR spawn point if no track.
	
	if agents.has(character.name):
		var agent = agents[character.name]
		# Find start pos: either from existing track at 0.0 or keep current if valid?
		# GDD says: "Po potvrzení se vrátí na start". Implies when we start NEXT recording, we start at A.
		
		# Let's check if we have data at 0.0
		var start_state = planning_manager.ghost_controller.get_state_at_time(character.name, 0.0)
		if not start_state.is_empty():
			agent.apply_state(start_state)
		else:
			# Fallback to spawn point (assumed current pos is close or reset needed)
			# agent.global_position = ... (Need to store spawn point)
			pass

func _on_mission_activated(mission: MissionData) -> void:
	load_level(mission.target_location)
	
	# Move visualizer to top
	if path_visualizer:
		path_visualizer.get_parent().remove_child(path_visualizer)
		blueprint_view.add_child(path_visualizer)
		
	spawn_team()

func load_level(path: String) -> void:
	# Clear previous level
	if current_level_node:
		current_level_node.queue_free()
		
	var level_packed = load(path)
	if level_packed:
		current_level_node = level_packed.instantiate()
		blueprint_view.add_child(current_level_node)
		blueprint_view.move_child(current_level_node, 0) 
		print("Level loaded: ", path)
	else:
		push_error("Failed to load level: " + path)

func spawn_team() -> void:
	# Clear existing agents
	for agent in agents.values():
		agent.queue_free()
	agents.clear()
	
	# Get team from manager
	var team = planning_manager.team
	if team.is_empty():
		push_warning("PlanningMode: Team is empty. Creating dummy.")
		var dummy = CharacterData.new()
		dummy.name = GameManager.player_name
		team.append(dummy)
	
	# Find StartPoint
	var start_point = current_level_node.find_child("StartPoint")
	var spawn_pos = Vector2(100, 100)
	if start_point:
		spawn_pos = start_point.position
	
	# Spawn all agents
	var agent_scene = load("res://scenes/agents/PlayerAgent.tscn")
	for char_data in team:
		var agent = agent_scene.instantiate()
		agent.position = spawn_pos
		blueprint_view.add_child(agent)
		
		agent.setup(char_data, planning_manager.ghost_controller)
		agent.set_mode(PlayerAgent.Mode.PLAYBACK) # Default to Ghost
		
		agents[char_data.name] = agent
		print("Spawned agent: ", char_data.name)
	
	# Select first character
	planning_manager.select_character(0)

func _on_character_selected(character: CharacterData) -> void:
	print("PlanningMode: Switching to ", character.name)
	
	for agent_name in agents:
		var agent = agents[agent_name]
		if agent_name == character.name:
			# Active Character
			agent.set_mode(PlayerAgent.Mode.MANUAL)
			# Move camera to this agent
			var cam = agent.find_child("TacticalCamera")
			if cam: cam.make_current()
		else:
			# Ghost Character
			agent.set_mode(PlayerAgent.Mode.PLAYBACK)

func _on_time_changed(time: float) -> void:
	# Update all GHOST agents to their position at 'time'
	var active_name = ""
	var active_char = planning_manager.team[planning_manager.selected_character_index] if not planning_manager.team.is_empty() else null
	if active_char:
		active_name = active_char.name
		
	var all_cones = get_tree().get_nodes_in_group("vision_cones")
		
	for agent_name in agents:
		var agent = agents[agent_name]
		if agent_name == active_name and planning_manager.ghost_controller.is_recording:
			# Even for active recording agent, we want to know if they are detected
			var detected = false
			for cone in all_cones:
				if cone.is_point_in_cone(agent.global_position):
					detected = true
					break
			agent.set_detection_warning(detected)
			
			if detected:
				planning_manager.ghost_controller.record_detection(agent_name, time)
				
			continue # Don't override active player input position
			
		var state = planning_manager.ghost_controller.get_state_at_time(agent_name, time)
		if not state.is_empty():
			agent.apply_state(state)
			
			# Check detection for ghost
			var detected = false
			for cone in all_cones:
				if cone.is_point_in_cone(agent.global_position):
					detected = true
					break
			agent.set_detection_warning(detected)
			
			if detected:
				planning_manager.ghost_controller.record_detection(agent_name, time)
			
	# Update Guards (Simulated Patrols)
	# We assume guards are children of current_level_node or easily accessible
	if current_level_node:
		var guards = current_level_node.find_children("*", "Guard", true, false)
		for guard in guards:
			if guard.has_method("set_timeline_time"):
				guard.set_timeline_time(time)

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"): 
		_on_start_action_pressed()

func _on_start_action_pressed():
	print("Finalizing Plan...")
	var final_plan = planning_manager.get_final_plan()
	
	if final_plan:
		print("Plan finalized with ", final_plan.characters.size(), " characters.")
		EventBus.action_phase_started.emit(final_plan)
		GameManager.change_state(GameManager.State.ACTION)
	else:
		push_error("Cannot start action: Invalid plan.")