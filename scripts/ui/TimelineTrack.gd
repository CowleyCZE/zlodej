extends Control

signal action_clicked(character: CharacterData, index: int)

var character_data: CharacterData
var char_plan: RefCounted # PlanningData.CharacterPlan - Reference due to cyclic type hint issues or resource casting
var duration: float = 600.0
var ghost_controller: GhostRunController

func setup_from_plan(p_char: CharacterData, p_plan, p_duration: float):
	character_data = p_char
	char_plan = p_plan
	duration = p_duration
	
	# Try to find ghost controller if not injected
	if not ghost_controller:
		var main = get_tree().current_scene
		if main.has_node("PlanningManager"):
			ghost_controller = main.get_node("PlanningManager").ghost_controller
	
	var label = get_node_or_null("Label")
	if label:
		label.text = p_char.name.left(3).to_upper()
	queue_redraw()

func _process(_delta):
	# Update visualization in real-time if simulation is running
	if ghost_controller and (ghost_controller.is_recording or ghost_controller.is_playing):
		queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var clicked_index = _get_action_at_position(event.position.x)
		if clicked_index != -1:
			action_clicked.emit(character_data, clicked_index)
			accept_event()

func _get_action_at_position(local_x: float) -> int:
	if duration <= 0 or not char_plan: return -1
	var px_per_sec = size.x / duration
	
	for i in range(char_plan.actions.size()):
		var action = char_plan.actions[i]
		var start_x = action.time * px_per_sec
		var width = action.duration * px_per_sec
		width = max(width, 5.0) # Min width for clickability
		
		if local_x >= start_x and local_x <= (start_x + width):
			return i
	return -1

func _draw():
	if duration <= 0 or not char_plan: return
	
	var w = size.x
	var h = size.y
	var px_per_sec = w / duration
	
	# Background (Blueprint Style)
	draw_rect(Rect2(0, 0, w, h), Color(0.05, 0.15, 0.3, 0.3))
	
	# Draw Detection Intervals (Danger Zones)
	if ghost_controller and ghost_controller.detection_intervals.has(character_data.name):
		var intervals = ghost_controller.detection_intervals[character_data.name]
		for interval in intervals:
			var start_x = interval.start * px_per_sec
			var end_x = interval.end * px_per_sec
			draw_rect(Rect2(start_x, 0, max(end_x - start_x, 1.0), h), Color(1.0, 0.0, 0.0, 0.4))

	# Draw Synchronization Delays (Hatched pattern)
	if ghost_controller and ghost_controller.playback_delays.has(character_data.name):
		var delays = ghost_controller.playback_delays[character_data.name]
		var accumulated_delay = 0.0
		for delay in delays:
			var start_x = (delay.at_time + accumulated_delay) * px_per_sec
			var width = delay.duration * px_per_sec
			
			if width > 0:
				var rect = Rect2(start_x, 2, width, h - 4)
				draw_rect(rect, Color(0.5, 0.5, 0.5, 0.2)) # Light grey backing
				
				# Hatching lines
				var line_spacing = 8.0
				var line_count = int(width / line_spacing) + 1
				for i in range(line_count):
					var lx = start_x + (i * line_spacing)
					draw_line(Vector2(lx, h - 4), Vector2(lx + 5, 4), Color(0.4, 0.4, 0.4, 0.5), 1.0)
			
			accumulated_delay += delay.duration

	# Draw Actions
	for i in range(char_plan.actions.size()):
		var action = char_plan.actions[i]
		var start_x = action.time * px_per_sec
		var width = action.duration * px_per_sec
		width = max(width, 2.0)
		var rect = Rect2(start_x, 4, width, h - 8)
		
		var col = Color.GRAY
		match action.type:
			"MOVE": col = Color(0.0, 1.0, 0.5, 0.7) # Green
			"INTERACT": col = Color(1.0, 0.8, 0.0, 0.8) # Gold
			"WAIT": col = Color(0.6, 0.2, 0.2, 0.7) # Red/Brown
			"RADIO": col = Color(0.2, 0.6, 1.0, 0.7) # Blue
			_: col = Color(0.5, 0.5, 0.5, 0.5)
			
		draw_rect(rect, col)
		draw_rect(rect, col.lightened(0.2), false, 1.0)
		
		# Draw Signal Dependency Indicator
		if action.wait_for_signal != "":
			draw_circle(Vector2(start_x, h/2), 3.0, Color.RED)
		
		# Draw Signal Emission Indicator
		if action.emit_signal_on_complete != "":
			draw_circle(Vector2(start_x + width, h/2), 3.0, Color.GREEN)

	# Separator
	draw_line(Vector2(0, h-1), Vector2(w, h-1), Color(0.0, 0.5, 1.0, 0.5), 1.0)
