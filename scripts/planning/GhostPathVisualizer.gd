class_name GhostPathVisualizer
extends Node2D

@export var line_width: float = 3.0
@export var active_color: Color = Color(1, 1, 1, 0.8) # White for current recording
@export var action_marker_size: float = 6.0
@export var wait_color: Color = Color(1.0, 0.8, 0.2, 0.9) # Yellowish for WAIT
@export var interact_color: Color = Color(0.3, 0.8, 1.0, 1.0) # Cyan for INTERACT (Art Bible)
@export var danger_color: Color = Color(0.94, 0.28, 0.44, 1.0) # Danger Red (#EF476F)

var ghost_controller: GhostRunController
var planning_manager: PlanningManager

# Hardcoded colors for team members (Cyan, Magenta, Orange, Green)
var team_colors: Array[Color] = [
	Color(0.2, 0.8, 1.0, 0.6), 
	Color(1.0, 0.2, 0.8, 0.6), 
	Color(1.0, 0.6, 0.0, 0.6), 
	Color(0.2, 1.0, 0.4, 0.6)
]

func setup(controller: GhostRunController, manager: PlanningManager = null) -> void:
	ghost_controller = controller
	planning_manager = manager

func _process(_delta: float) -> void:
	# Continuous redraw to show live updates
	queue_redraw()

func _draw() -> void:
	if not ghost_controller:
		return
		
	# 1. Draw completed (ghost) tracks
	var color_idx = 0
	for char_name in ghost_controller.recorded_tracks:
		# Skip if this character is currently being re-recorded (handled by buffer)
		if ghost_controller.is_recording and ghost_controller.active_character and ghost_controller.active_character.name == char_name:
			color_idx += 1
			continue
			
		var track = ghost_controller.recorded_tracks[char_name]
		var color = team_colors[color_idx % team_colors.size()]
		
		_draw_track(track, color)
		
		# Draw markers from plan if available
		if planning_manager and planning_manager.current_plan:
			_draw_plan_markers(char_name, track)
			
		color_idx += 1
	
	# 2. Draw current live recording buffer
	if ghost_controller.is_recording:
		_draw_track(ghost_controller.current_recording_buffer, active_color)
		
	# 3. Draw validation errors (Collisions, etc.)
	if planning_manager and not planning_manager.validation_errors.is_empty():
		_draw_validation_errors()

func _draw_validation_errors() -> void:
	for error in planning_manager.validation_errors:
		if error["type"] == "COLLISION":
			var pos = error["pos"]
			var size = action_marker_size * 1.5
			
			# Draw a stylized X
			draw_line(pos - Vector2(size, size), pos + Vector2(size, size), danger_color, 2.0)
			draw_line(pos - Vector2(size, -size), pos + Vector2(size, -size), danger_color, 2.0)
			
			# Background glow for the error
			draw_circle(pos, size * 1.2, Color(danger_color.r, danger_color.g, danger_color.b, 0.2))

func _draw_track(track_data: Array, color: Color) -> void:
	if track_data.size() < 2:
		return
		
	var points = PackedVector2Array()
	for frame in track_data:
		points.append(frame["pos"])
		
	draw_polyline(points, color, line_width, true)
	
	# Draw start and end points
	draw_circle(points[0], line_width * 1.5, color)
	draw_circle(points[points.size() - 1], line_width * 1.5, color)

func _draw_plan_markers(char_name: String, track: Array) -> void:
	if not planning_manager.current_plan.character_plans.has(char_name):
		return
		
	var char_plan = planning_manager.current_plan.character_plans[char_name]
	
	for action in char_plan.actions:
		# Find position at action time
		var pos = _find_pos_in_track(track, action.time)
		
		if action.type == "WAIT" or action.wait_for_signal != "":
			# Draw WAIT marker (Circle with hole or clock style)
			draw_circle(pos, action_marker_size, wait_color)
			draw_circle(pos, action_marker_size * 0.6, Color(0,0,0,0.5)) # Inner hole for "clock" look
		elif action.type == "INTERACT":
			# Draw INTERACT marker (Diamond/Square)
			var rect = Rect2(pos - Vector2(action_marker_size, action_marker_size), Vector2(action_marker_size*2, action_marker_size*2))
			draw_rect(rect, interact_color, true)
			draw_rect(rect, Color.WHITE, false, 1.0) # White outline

func _find_pos_in_track(track: Array, time: float) -> Vector2:
	if track.is_empty(): return Vector2.ZERO
	
	# Simple linear search (tracks are sorted by time)
	for i in range(track.size() - 1):
		if track[i].time <= time and track[i+1].time > time:
			var t_start = track[i].time
			var t_end = track[i+1].time
			var weight = (time - t_start) / (t_end - t_start)
			return track[i].pos.lerp(track[i+1].pos, weight)
			
	return track.back().pos
