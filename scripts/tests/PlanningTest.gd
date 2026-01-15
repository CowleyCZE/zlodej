extends Node

func _ready():
	print("--- STARTING PLANNING TEST ---")
	
	# 1. Setup Planning Scene
	var planning_manager = PlanningManager.new()
	# PlanningManager needs to be in tree because it creates GhostRunController
	add_child(planning_manager)
	
	var char_a = CharacterData.new()
	char_a.name = "Petra"
	var char_b = CharacterData.new()
	char_b.name = "Josef"
	
	var team_data: Array[CharacterData] = [char_a, char_b]
	planning_manager.team = team_data
	
	var mission = MissionData.new()
	mission.mission_id = "test_mission"
	# Initialize plan
	planning_manager._on_planning_activated(mission)
	
	var ghost_ctrl = planning_manager.ghost_controller
	
	# 2. Record simple track for Petra (char_a)
	# Moves from (0,0) to (100,0) in 2 seconds
	print("TEST: Recording track for Petra...")
	ghost_ctrl.start_recording(char_a)
	for i in range(21): # 0.0 to 2.0s
		var t = i * 0.1
		# Manually manipulate time for test
		ghost_ctrl.current_time = t
		ghost_ctrl.record_frame(Vector2(t * 50, 0), Vector2(50, 0), {})
	ghost_ctrl.stop_recording(true)
	
	# 3. Setup Signal Synchronization
	# Josef (char_b) waits for signal 'go'
	print("TEST: Setting up Signal Synchronization...")
	# Josef needs a track too to test effective time, even if static
	ghost_ctrl.start_recording(char_b)
	ghost_ctrl.record_frame(Vector2(0,0), Vector2(0,0), {})
	ghost_ctrl.stop_recording(true)

	var plan_b = planning_manager.current_plan.get_or_create_plan_for(char_b)
	var action_wait = PlanningData.TimelineAction.new()
	action_wait.time = 0.5
	action_wait.type = "WAIT"
	action_wait.wait_for_signal = "go"
	action_wait.duration = 0.0 # Just waiting for signal
	plan_b.actions.append(action_wait)
	
	# Petra (char_a) emits signal 'go' at 1.0s
	var plan_a = planning_manager.current_plan.get_or_create_plan_for(char_a)
	var action_emit = PlanningData.TimelineAction.new()
	action_emit.time = 1.0
	action_emit.type = "INTERACT"
	action_emit.emit_signal_on_complete = "go"
	action_emit.duration = 0.5 # Finishes at 1.5
	plan_a.actions.append(action_emit)
	
	ghost_ctrl.set_plan(planning_manager.current_plan)
	
	# 4. Verify Effective Time (Signal Wait)
	print("TEST: Verifying effective time for Josef (Waiting)...")
	# At global time 1.0, Petra is at effective 1.0 (emits signal at 1.5 because 1.0 + 0.5 duration)
	# Josef should be stuck at 0.5 until global 1.5
	
	var eff_josef_early = ghost_ctrl.get_effective_time("Josef", 1.0)
	print("Josef eff time at global 1.0: ", eff_josef_early)
	if abs(eff_josef_early - 0.5) > 0.01:
		print("FAIL: Josef should be waiting at 0.5!")
		get_tree().quit(1)
		return
		
	var eff_josef_late = ghost_ctrl.get_effective_time("Josef", 2.0)
	print("Josef eff time at global 2.0: ", eff_josef_late)
	# Signal emitted at 1.5. 
	# At global 2.0, Josef has been "released" for 0.5s.
	# So his effective time should be his wait position (0.5) + 0.5 = 1.0
	if abs(eff_josef_late - 1.0) > 0.01:
		print("FAIL: Josef should have progressed to 1.0! Got: ", eff_josef_late)
		get_tree().quit(1)
		return
	
	print("SUCCESS: Signal synchronization logic verified.")

	# 5. Test Vision Detection in Planning
	print("TEST: Verifying Vision Detection feedback...")
	var cone_scene = load("res://scenes/objects/VisionCone.tscn")
	var cone = cone_scene.instantiate()
	cone.radius = 100.0
	cone.angle_deg = 90.0
	add_child(cone)
	cone.global_position = Vector2(0, 0) 
	cone.global_rotation = 0 # Looking right
	
	# Point at (50, 0) should be in cone
	if not cone.is_point_in_cone(Vector2(50, 0)):
		print("FAIL: Point (50,0) should be in cone!")
		get_tree().quit(1)
		return
		
	# Point behind should not
	if cone.is_point_in_cone(Vector2(-50, 0)):
		print("FAIL: Point (-50,0) should NOT be in cone (behind)!")
		get_tree().quit(1)
		return

	print("--- PLANNING TEST PASSED ---")
	# Removed quit to allow log capture
