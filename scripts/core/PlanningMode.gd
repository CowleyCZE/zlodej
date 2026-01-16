extends Node2D

@onready var planning_manager = $PlanningManager
@onready var recording_hud: RecordingHUD = $CanvasLayer/RecordingHUD
@onready var blueprint_view: Node2D = $BlueprintView

# Top Strip UI References (Linked from Game.tscn or internal if standalone)
var lbl_time: Label
var lbl_obj_name: Label
var lbl_obj_desc: Label

var current_level_node: Node2D
var agents: Dictionary = {} # character_name (String) -> PlayerAgent (Node)
var path_visualizer
var soundscape: PlanningSoundscape

func _ready():
	# Find UI elements in the global shell
	var game = get_tree().root.find_child("Game", true, false)
	if game:
		lbl_time = game.get_node_or_null("CanvasLayer/GlobalUI/TopStrip/HBox/TimeWeather/TimeLabel")
		lbl_obj_name = game.get_node_or_null("CanvasLayer/GlobalUI/TopStrip/HBox/MainInfo/Title")
		lbl_obj_desc = game.get_node_or_null("CanvasLayer/GlobalUI/TopStrip/HBox/MainInfo/SubTitle")

	# Add Soundscape
	soundscape = PlanningSoundscape.new()
	add_child(soundscape)
	
	# Initialize HUD with Manager reference
	if recording_hud and planning_manager:
		recording_hud.setup(planning_manager)
		recording_hud.inspection_requested.connect(_on_object_inspected)
	
	# Setup Visualizer
	var vis_scene = load("res://scenes/planning/GhostPathVisualizer.tscn")
	if vis_scene:
		path_visualizer = vis_scene.instantiate()
		path_visualizer.setup(planning_manager.ghost_controller, planning_manager)
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

func _on_object_inspected(obj_name: String, obj_desc: String):
	if lbl_obj_name: lbl_obj_name.text = obj_name.to_upper()
	if lbl_obj_desc:
		var matt_comment = MattManager.get_object_comment(obj_name)
		lbl_obj_desc.text = obj_desc + " | Matt: \"" + matt_comment + "\""
	
	# Visual feedback
	var tween = create_tween()
	if lbl_obj_name:
		lbl_obj_name.modulate = Color.CYAN
		tween.tween_property(lbl_obj_name, "modulate", Color.WHITE, 0.5)

func _on_time_changed(time: float) -> void:
	if lbl_time:
		var minutes = int(time / 60.0)
		var seconds = fmod(time, 60.0)
		lbl_time.text = "%02d:%04.1f" % [minutes, seconds]

	# Update all GHOST agents to their position at 'time'
	var active_name = ""
	var active_char = planning_manager.team[planning_manager.selected_character_index] if not planning_manager.team.is_empty() else null
	if active_char:
		active_name = active_char.name
		
	var all_cones = get_tree().get_nodes_in_group("vision_cones")
		
	for agent_name in agents:
		var agent = agents[agent_name]
		if agent_name == active_name and planning_manager.ghost_controller.is_recording:
			var detected = false
			for cone in all_cones:
				if cone.is_point_in_cone(agent.global_position):
					detected = true
					break
			agent.set_detection_warning(detected)
			if detected:
				planning_manager.ghost_controller.record_detection(agent_name, time)
			continue 
		
		var state = planning_manager.ghost_controller.get_state_at_time(agent_name, time)
		if not state.is_empty():
			agent.apply_state(state)
			var detected = false
			for cone in all_cones:
				if cone.is_point_in_cone(agent.global_position):
					detected = true
					break
			agent.set_detection_warning(detected)
			if detected:
				planning_manager.ghost_controller.record_detection(agent_name, time)
		
	if current_level_node:
		var guards = current_level_node.find_children("*", "Guard", true, false)
		for guard in guards:
			if guard.has_method("set_timeline_time"):
				guard.set_timeline_time(time)

func _on_recording_started(character: CharacterData) -> void:
	if agents.has(character.name):
		var agent = agents[character.name]
		var start_state = planning_manager.ghost_controller.get_state_at_time(character.name, 0.0)
		if not start_state.is_empty():
			agent.apply_state(start_state)

func _on_mission_activated(mission: MissionData) -> void:
	load_level(mission.target_location)
	if path_visualizer:
		path_visualizer.get_parent().remove_child(path_visualizer)
		blueprint_view.add_child(path_visualizer)
	spawn_team()

func load_level(path: String) -> void:
	if current_level_node:
		current_level_node.queue_free()
	var level_packed = load(path)
	if level_packed:
		current_level_node = level_packed.instantiate()
		blueprint_view.add_child(current_level_node)
		blueprint_view.move_child(current_level_node, 0) 
	if GameManager.current_mission:
		_apply_intel_fog(GameManager.current_mission)
	else:
		push_error("Failed to load level: " + path)

func _apply_intel_fog(mission: MissionData) -> void:
	var has_arch = mission.intel_flags.get("architecture", false)
	var game = get_tree().root.find_child("Game", true, false)
	if game:
		var overlay = game.find_child("BlueprintOverlay", true, false)
		if overlay and overlay.material is ShaderMaterial:
			overlay.material.set_shader_parameter("reveal_intensity", 1.0 if has_arch else 0.15)
	
	var guards = get_tree().get_nodes_in_group("guards")
	var hide_guards = not mission.intel_flags.get("patrols", false)
	for guard in guards:
		if is_ancestor_of(guard) or current_level_node.is_ancestor_of(guard):
			guard.visible = !hide_guards
	
	var cameras = get_tree().get_nodes_in_group("security_cameras")
	var hide_cameras = not mission.intel_flags.get("security", false)
	for camera in cameras:
		if is_ancestor_of(camera) or current_level_node.is_ancestor_of(camera):
			camera.visible = !hide_cameras
	
	var loot_items = get_tree().get_nodes_in_group("loot")
	var hide_loot = not mission.intel_flags.get("treasure", false)
	for loot in loot_items:
		if is_ancestor_of(loot) or current_level_node.is_ancestor_of(loot):
			loot.visible = !hide_loot

func spawn_team() -> void:
	for agent in agents.values():
		agent.queue_free()
	agents.clear()
	var team = planning_manager.team
	if team.is_empty():
		var dummy = CharacterData.new()
		dummy.name = "Thief"
		team.append(dummy)
	var start_point = current_level_node.find_child("StartPoint")
	var spawn_pos = start_point.position if start_point else Vector2(100, 100)
	# Spawn all agents
	var agent_scene = load("res://scenes/agents/PlayerAgent.tscn")
	for char_data in team:
		var agent = agent_scene.instantiate()
		agent.position = spawn_pos
		blueprint_view.add_child(agent)
		agent.setup(char_data, planning_manager.ghost_controller)
		agent.set_mode(PlayerAgent.Mode.PLAYBACK) 
		agents[char_data.name] = agent
	planning_manager.select_character(0)

func _on_character_selected(character: CharacterData) -> void:
	for agent_name in agents:
		var agent = agents[agent_name]
		if agent_name == character.name:
			agent.set_mode(PlayerAgent.Mode.MANUAL)
			var cam = agent.find_child("TacticalCamera")
			if cam: cam.make_current()
		else:
			agent.set_mode(PlayerAgent.Mode.PLAYBACK)

func _on_start_action_pressed():
	var final_plan = planning_manager.get_final_plan()
	if final_plan:
		EventBus.action_phase_started.emit(final_plan)
		GameManager.change_state(GameManager.State.ACTION)

func _debug_start_tutorial():
	if AdventureManager.hired_characters.is_empty():
		var debug_char = CharacterData.new()
		debug_char.name = "Debug Thief"
		AdventureManager.hired_characters.append(debug_char)
	var mission = load("res://resources/Missions/Mission_Tutorial.tres")
	if mission:
		EventBus.planning_activated.emit(mission)

func _on_action_triggered(char_name: String, type: String, data: Dictionary) -> void:
	if agents.has(char_name):
		agents[char_name].execute_plan_action(type, data)