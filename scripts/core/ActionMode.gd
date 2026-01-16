extends Node2D

@onready var world_container: Node2D = $WorldContainer
@onready var hud_time_label: Label = $CanvasLayer/Panel/TimeLabel
@onready var hud_status_label: Label = $CanvasLayer/Panel/StatusLabel

var current_plan: PlanningData
var ghost_controller: GhostRunController
var agents: Dictionary = {} # name -> PlayerAgent instance
var execution_time: float = 0.0
var is_executing: bool = false

# Stats Tracking
var stats_guards_stunned: int = 0
var stats_guards_killed: int = 0
var stats_times_spotted: int = 0

func _ready() -> void:
	# Setup Ghost Controller for Playback
	ghost_controller = GhostRunController.new()
	# Connect signal for actions
	ghost_controller.action_triggered.connect(_on_action_triggered)
	add_child(ghost_controller)
	
	# Connect EventBus signals
	EventBus.mission_completed.connect(_on_mission_completed)
	EventBus.mission_failed.connect(_on_mission_failed)
	
	EventBus.guard_stunned.connect(func(_g): stats_guards_stunned += 1)
	EventBus.guard_killed.connect(func(_g): stats_guards_killed += 1)
	EventBus.player_spotted.connect(func(_p): stats_times_spotted += 1)
	
	print("Action Mode Initialized. Waiting for plan...")
	hud_status_label.text = "WAITING FOR PLAN..."

func _on_mission_completed(mission_id: String):
	print("MISSION COMPLETED: ", mission_id)
	is_executing = false
	hud_status_label.text = "SUCCESS!"
	_finalize_results(true)
	await get_tree().create_timer(2.0).timeout
	GameManager.change_state(GameManager.State.RESULTS)

func _on_mission_failed(reason: String):
	print("MISSION FAILED: ", reason)
	is_executing = false
	hud_status_label.text = "FAILED: " + reason
	_finalize_results(false)
	await get_tree().create_timer(2.0).timeout
	GameManager.change_state(GameManager.State.RESULTS)

func _finalize_results(success: bool):
	GameManager.last_mission_results = {
		"success": success,
		"loot_collected": GameManager.current_mission_loot,
		"guards_stunned": stats_guards_stunned,
		"guards_killed": stats_guards_killed,
		"times_spotted": stats_times_spotted,
		"team_members": current_plan.characters if current_plan else []
	}
	
	# Add base reward to loot if success
	if success and GameManager.current_mission:
		GameManager.last_mission_results["loot_collected"] += GameManager.current_mission.base_reward

func _on_action_triggered(char_name: String, action_type: String, data: Dictionary) -> void:
	print("Action Triggered: ", char_name, " -> ", action_type, " ", data)
	
	# Handle Gadget Usage (Interactions)
	if action_type == "INTERACT" or action_type == "USE_ITEM":
		var tool_id = data.get("tool_id", "")
		if tool_id != "":
			var agent = agents.get(char_name)
			if agent:
				var GadgetSystem = load("res://scripts/systems/GadgetEffectSystem.gd")
				GadgetSystem.apply_gadget_effect(tool_id, agent, world_container)

func setup_execution(plan: PlanningData) -> void:
	current_plan = plan
	execution_time = 0.0
	is_executing = true
	hud_status_label.text = "EXECUTING: " + (plan.mission_id if plan.mission_id != "" else "HEIST")
	
	# Load recorded tracks from metadata (Sourced from PlanningManager)
	if plan.has_meta("recorded_tracks"):
		ghost_controller.recorded_tracks = plan.get_meta("recorded_tracks")
		print("Action Mode: Loaded ", ghost_controller.recorded_tracks.size(), " character tracks.")
	else:
		push_error("Action Mode: No recorded tracks found in plan metadata!")
	
	# Recalculate delays based on the plan's actions
	ghost_controller.set_plan(plan)
	
	# Load Level
	var level_path = "res://scenes/levels/Level_Tutorial.tscn" # Fallback
	if GameManager.current_mission and GameManager.current_mission.target_location != "":
		level_path = GameManager.current_mission.target_location
	
	print("Loading level: ", level_path)
	
	var level_res = load(level_path)
	if level_res:
		var level = level_res.instantiate()
		world_container.add_child(level)
	
	# Spawn Agents
	var player_node = null
	for char_data in plan.characters:
		var agent = _spawn_agent(char_data)
		# Assuming first agent is controlled by camera or is main?
		# For indicators we need a reference point. Usually the camera follow target.
		if not player_node: player_node = agent

	# Setup Indicators
	if player_node:
		_setup_guard_indicators(player_node)

func _spawn_agent(data: CharacterData) -> Node2D:
	var agent_scene = load("res://scenes/agents/PlayerAgent.tscn")
	var agent = agent_scene.instantiate()
	world_container.add_child(agent)
	agent.setup(data, ghost_controller)
	agent.set_mode(PlayerAgent.Mode.PLAYBACK)
	agents[data.name] = agent
	
	# Set initial position
	var start_state = ghost_controller.get_state_at_time(data.name, 0.0)
	agent.apply_state(start_state)
	
	return agent

func _setup_guard_indicators(player_node):
	var hud = get_tree().get_first_node_in_group("hud")
	if not hud: return
	
	var guards = get_tree().get_nodes_in_group("guards")
	for guard in guards:
		hud.spawn_detection_indicator(guard, player_node)

func _physics_process(delta: float) -> void:
	if not is_executing: return
	
	execution_time += delta
	hud_time_label.text = "T+ %.2f s" % execution_time
	
	# Update all agents
	var longest_track = 0.0
	for agent_name in agents:
		var state = ghost_controller.get_state_at_time(agent_name, execution_time)
		agents[agent_name].apply_state(state)
		
		# Find the duration of this character's track
		if ghost_controller.recorded_tracks.has(agent_name):
			var track = ghost_controller.recorded_tracks[agent_name]
			if not track.is_empty():
				longest_track = max(longest_track, track.back()["time"])
	
	# Auto-finish if we surpassed the longest track + buffer
	if execution_time > longest_track + 2.0 and execution_time > 5.0:
		print("Action Mode: All tracks finished. Finalizing mission.")
		is_executing = false
		_on_mission_completed(current_plan.mission_id if current_plan else "unknown")
	
	if execution_time >= 600.0: # Hard limit 10m
		is_executing = false
		print("Execution finished.")

func _on_abort_pressed():
	# Return to menu or report
	GameManager.change_state(GameManager.State.RESULTS)
