class_name GhostPathVisualizer
extends Node2D

@export var line_width: float = 3.0
@export var active_color: Color = Color(1, 1, 1, 0.8) # White for current recording

var ghost_controller: GhostRunController
# Hardcoded colors for team members (Cyan, Magenta, Orange, Green)
var team_colors: Array[Color] = [
	Color(0.2, 0.8, 1.0, 0.6), 
	Color(1.0, 0.2, 0.8, 0.6), 
	Color(1.0, 0.6, 0.0, 0.6), 
	Color(0.2, 1.0, 0.4, 0.6)
]

func setup(controller: GhostRunController) -> void:
	ghost_controller = controller

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
		if ghost_controller.is_recording and ghost_controller.active_character.name == char_name:
			color_idx += 1
			continue
			
		var track = ghost_controller.recorded_tracks[char_name]
		var color = team_colors[color_idx % team_colors.size()]
		
		_draw_track(track, color)
		color_idx += 1
	
	# 2. Draw current live recording buffer
	if ghost_controller.is_recording:
		_draw_track(ghost_controller.current_recording_buffer, active_color)

func _draw_track(track_data: Array, color: Color) -> void:
	if track_data.size() < 2:
		return
		
	var points = PackedVector2Array()
	# Optimization: Don't draw every single point if recording is dense
	# But for MVP, drawing all is safer for accuracy
	for frame in track_data:
		points.append(frame["pos"])
		
	draw_polyline(points, color, line_width, true) # Antialiased
	
	# Draw start and end points
	draw_circle(points[0], line_width * 1.5, color)
	draw_circle(points[points.size() - 1], line_width * 1.5, color)
