extends Control

# Signals
signal planning_completed(plan_data)
signal planning_cancelled

# UI References - Top Panel
@onready var top_panel = $VBoxContainer/TopPanel
@onready var status_label = $VBoxContainer/TopPanel/VBoxContainer/HeaderRow/StatusLabel
@onready var timeline_slider = $VBoxContainer/TopPanel/VBoxContainer/HeaderRow/TimelineSlider
@onready var char_buttons_container = $VBoxContainer/TopPanel/VBoxContainer/CharacterBar/CharButtons
@onready var active_char_label = $VBoxContainer/TopPanel/VBoxContainer/InfoRow/ActiveCharLabel
@onready var log_container = $VBoxContainer/TopPanel/VBoxContainer/ScrollContainer/LogVBox

# UI References - Middle Panel
@onready var map_canvas = $VBoxContainer/MiddlePanel
@onready var tile_map = $VBoxContainer/MiddlePanel/TileMap
@onready var entities_layer = $VBoxContainer/MiddlePanel/EntitiesLayer
@onready var route_lines_layer = $VBoxContainer/MiddlePanel/RouteLinesLayer
@onready var ghost_lines_layer = $VBoxContainer/MiddlePanel/GhostLinesLayer

# UI References - Bottom Panel
# State
@onready var bottom_menu = $VBoxContainer/BottomMenu

var planning_manager = null # Typed dynamically to avoid cyclic deps if class_name not avail
var active_character_data = null
var character_sprites: Dictionary = {}
var is_dragging: bool = false

# State
var temp_path_points: PackedVector2Array = []
var simulation_running: bool = false
var is_panning: bool = false

# Mock Level Data (would be loaded from TileMap/Mission)
var _interactables = {
	Vector2(4, 3): {"type": "door_locked", "name": "Vchodové dveře", "skill": "lockpick", "difficulty": 2},
	Vector2(4, 5): {"type": "door", "name": "Dveře do kuchyně", "skill": "none"},
	Vector2(7, 3): {"type": "window", "name": "Okno", "skill": "none"},
	Vector2(2, 2): {"type": "safe", "name": "Trezor", "skill": "safecrack", "difficulty": 4},
	Vector2(6, 6): {"type": "alarm_panel", "name": "Alarm", "skill": "electronics", "difficulty": 3}
}
# Current interaction context
var _current_context_obj = null


func _ready():
	_update_ui_state()

func _process(_delta):
	if top_panel.get_node_or_null("MinimapContainer"):
		_update_minimap()

func _update_minimap():
	var minimap_rect = top_panel.get_node("MinimapContainer/ViewportRect")
	if not minimap_rect: return
	
	# Assume map size is 1200x1200 (as per user spec) or dynamic
	# For prototype we use fixed ratio. 
	# Real implementation should get true size of TileMap.
	var map_size = Vector2(1200, 1200)
	var viewport_size = map_canvas.size
	
	# Current scroll position is implied by map_canvas.position (negative)
	var scroll_pos = - map_canvas.position
	
	# Minimap size
	var mm_container = top_panel.get_node("MinimapContainer")
	var mm_size = mm_container.size
	
	# Ratios
	var ratio_x = mm_size.x / map_size.x
	var ratio_y = mm_size.y / map_size.y
	
	minimap_rect.size = viewport_size * Vector2(ratio_x, ratio_y)
	minimap_rect.position = scroll_pos * Vector2(ratio_x, ratio_y)

	
	# Propojení tlačítek
	# Bottom Menu Connections
	# Check for new nodes from scene update
	var dpad = bottom_menu.find_child("DPadContainer", true, false)
	if dpad:
		dpad.get_node("BtnUp").pressed.connect(func(): _move_active_character(Vector2.UP))
		dpad.get_node("BtnDown").pressed.connect(func(): _move_active_character(Vector2.DOWN))
		dpad.get_node("BtnLeft").pressed.connect(func(): _move_active_character(Vector2.LEFT))
		dpad.get_node("BtnRight").pressed.connect(func(): _move_active_character(Vector2.RIGHT))
	
	var actions = bottom_menu.find_child("ActionsContainer", true, false)
	if actions:
		actions.get_node("BtnUse").pressed.connect(_on_BtnUse_pressed)
		actions.get_node("BtnWait").pressed.connect(_on_BtnWait_pressed)
		actions.get_node("BtnOpen").pressed.connect(func(): _add_interact_action("OPEN"))
		actions.get_node("BtnPick").pressed.connect(func(): _add_interact_action("PICK"))
		
		# Initial state: Disable actions until context found
		actions.get_node("BtnUse").disabled = true
		actions.get_node("BtnOpen").disabled = true
		actions.get_node("BtnPick").disabled = true
		
	var sim = bottom_menu.find_child("SimContainer", true, false)
	if sim:
		sim.get_node("BtnSimulate").pressed.connect(_on_BtnSimulate_pressed)
		sim.get_node("BtnExecute").pressed.connect(_on_BtnExecute_pressed)
	
	if not timeline_slider.value_changed.is_connected(_on_timeline_changed):
		timeline_slider.value_changed.connect(_on_timeline_changed)
	
	# Attempt to find PlanningManager if not injected explicitly
	if not planning_manager:
		var root = get_tree().root
		# Try to find singleton or global node
		if root.has_node("PlanningManager"):
			initialize(root.get_node("PlanningManager"))
		elif get_tree().current_scene.has_node("PlanningManager"):
			initialize(get_tree().current_scene.get_node("PlanningManager"))
		else:
			# Fallback for standalone testing
			_setup_mock_scene_fallback()

	# Úvodní fade in efekt
	modulate.a = 0
	create_tween().tween_property(self, "modulate:a", 1.0, 0.5)

func initialize(manager: PlanningManager):
	print("PlanningPhase: Initializing with PlanningManager")
	planning_manager = manager
	planning_manager.plan_updated.connect(_on_plan_updated)
	planning_manager.character_selected.connect(_on_character_selected_from_manager)
	
	_load_mission_context()
	_refresh_characters()
	_update_timeline_max()

func _load_mission_context():
	if planning_manager and planning_manager.current_plan:
		status_label.text = "Plánování: Mise " + planning_manager.current_plan.mission_id
		add_log("Načten kontext mise")
		_draw_action_markers()
	else:
		status_label.text = "Plánování: Neznámá mise"

func _setup_mock_scene_fallback():
	add_log("⚠️ PlanningManager nenalezen. Spouštím TEST mode.")
	# Create a dummy manager implementation or just minimal data to prevent crash
	# For now, we will just warn. The original mock logic is being replaced.
	
func _refresh_characters():
	# Clear old sprites
	for s in entities_layer.get_children():
		s.queue_free()
	character_sprites.clear()
	
	# Clear old route lines
	for l in route_lines_layer.get_children():
		l.queue_free()
		
	# Clear UI buttons
	for child in char_buttons_container.get_children():
		child.queue_free()
	
	if not planning_manager: return
	
	for i in range(planning_manager.team.size()):
		var char_data = planning_manager.team[i]
		_create_character_visuals(char_data, i)
		_create_character_ui_button(char_data, i)

func _create_character_visuals(char_data: CharacterData, _index: int):
	var sprite = Sprite2D.new()
	var tex = PlaceholderTexture2D.new()
	tex.size = Vector2(32, 32)
	sprite.texture = tex
	# Generate unique color based on name hash or index
	var color = Color.from_hsv((char_data.name.hash() % 100) / 100.0, 0.7, 0.9)
	sprite.modulate = color
	# Default position (should come from entry point)
	sprite.position = Vector2(100 + _index * 50, 100)
	
	# Name label
	var lbl = Label.new()
	lbl.text = char_data.name
	lbl.position = Vector2(-20, -40)
	sprite.add_child(lbl)
	
	entities_layer.add_child(sprite)
	character_sprites[char_data] = sprite
	
	# Route Line
	var line = Line2D.new()
	line.name = "Route_" + char_data.name
	line.width = 4.0
	line.default_color = color
	route_lines_layer.add_child(line)

func _create_character_ui_button(char_data: CharacterData, index: int):
	var btn = Button.new()
	btn.text = char_data.name
	btn.custom_minimum_size = Vector2(100, 30)
	btn.pressed.connect(func(): planning_manager.select_character(index))
	char_buttons_container.add_child(btn)

func _on_character_selected_from_manager(char_data: CharacterData):
	active_character_data = char_data
	active_char_label.text = "Aktivní: " + char_data.name
	
	# Visual highlight
	for c in character_sprites:
		var sprite = character_sprites[c]
		sprite.modulate.a = 1.0 if c == char_data else 0.5
		
	add_log("Vybrán: " + char_data.name)

func enter_planning(target_building_data):
	status_label.text = "Plánování: %s | Čas: 00:00" % target_building_data.get("name", "Neznámé")
	add_log("Načten půdorys pro " + target_building_data.get("name", "Neznámé"))

func _input(event):
	# Panning (Right Click Drag) - Allowed anytime
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed: is_panning = true
			else: is_panning = false
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_map(0.1)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_map(-0.1)
			
	if event is InputEventMouseMotion and is_panning:
		map_canvas.position += event.relative

	if simulation_running: return # Block editing only after panning check
		
	# Keyboard Movement (Grid Logic)
	if active_character_data:
		if event.is_action_pressed("ui_up"): _move_active_character(Vector2.UP)
		elif event.is_action_pressed("ui_down"): _move_active_character(Vector2.DOWN)
		elif event.is_action_pressed("ui_left"): _move_active_character(Vector2.LEFT)
		elif event.is_action_pressed("ui_right"): _move_active_character(Vector2.RIGHT)
		
	# Character Switching (Tab or 1-4)
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_TAB:
			_cycle_character_selection()
		elif event.keycode >= KEY_1 and event.keycode <= KEY_4:
			var idx = event.keycode - KEY_1
			if planning_manager and idx < planning_manager.team.size():
				planning_manager.select_character(idx)

	# Original logic kept for fallback/legacy support or direct selection
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_try_select_character(event.position)
			
	if event is InputEventKey and event.is_action_pressed("ui_cancel"):
		emit_signal("planning_cancelled")
		add_log("Plánování zrušeno")
		
func _move_active_character(direction: Vector2):
	if not active_character_data or not planning_manager: return
	if simulation_running: return
	
	var step_size = 32.0 # One tile
	var plan = planning_manager.current_plan.get_or_create_plan_for(active_character_data)
	
	# Determine start position for this move (last waypoint or current sprite pos)
	var start_pos = Vector2.ZERO
	if not plan.waypoints.is_empty():
		start_pos = plan.waypoints.back().position
	elif active_character_data in character_sprites:
		start_pos = character_sprites[active_character_data].position
		# Ensure we mark start if this is first move
		var start_wp = PlanningData.TimelineWaypoint.new()
		start_wp.position = start_pos
		start_wp.time = 0.0 # Or last action end
		plan.waypoints.append(start_wp)
		
	var target_pos = start_pos + (direction * step_size)
	
	# Visual Feedback immediately
	if active_character_data in character_sprites:
		character_sprites[active_character_data].position = target_pos
		
	# Record to Plan
	var distance = step_size
	var speed = 150.0 # px/s
	var duration = distance / speed
	
	# Add Waypoint
	var last_time = plan.waypoints.back().time if not plan.waypoints.is_empty() else 0.0
	var new_time = last_time + duration
	
	var wp = PlanningData.TimelineWaypoint.new()
	wp.position = target_pos
	wp.time = new_time
	wp.speed = 1.0
	plan.waypoints.append(wp)
	
	# Add Action (Implied Move)
	# Note: Moving generally creates a stream of actions or one big MOVE. 
	# For turn-based, maybe we aggregate? For now, simplistic approach:
	# Check if last action was MOVE. If so, extend it.
	var added_to_last = false
	if not plan.actions.is_empty():
		var last_action = plan.actions.back()
		if last_action.type == "MOVE":
			last_action.duration += duration
			# Update visually?
			added_to_last = true
			
	if not added_to_last:
		var move_action = PlanningData.TimelineAction.new()
		move_action.time = last_time
		move_action.type = "MOVE"
		move_action.duration = duration
		plan.actions.append(move_action)
	
	# Redraw Route
	var line = route_lines_layer.get_node_or_null("Route_" + active_character_data.name)
	if line:
		line.add_point(target_pos)
		
	add_log("%s: Move %s (%.1fs)" % [active_character_data.name, str(direction), duration])
	
	# Check Context after move
	_check_interaction_context(target_pos)
	
	planning_manager.plan_updated.emit()

func _check_interaction_context(pos: Vector2):
	var grid_pos = (pos / 32.0).floor()
	# Check adjacent cells for interactables
	var found = null
	
	var directions = [Vector2.ZERO, Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	for d in directions:
		var check_pos = grid_pos + d
		if _interactables.has(check_pos):
			found = _interactables[check_pos]
			found["grid_pos"] = check_pos # inject pos for ref
			break
	
	_current_context_obj = found
	_update_action_buttons(found)

func _update_action_buttons(context: Dictionary):
	var actions = bottom_menu.find_child("ActionsContainer", true, false)
	if not actions: return
	
	var btn_use = actions.get_node("BtnUse")
	var btn_open = actions.get_node("BtnOpen")
	var btn_pick = actions.get_node("BtnPick")
	
	# Reset ALL to disabled
	btn_use.disabled = true
	btn_open.disabled = true
	btn_pick.disabled = true
	
	if context == null:
		status_label.text = "Plánování: " + planning_manager.current_plan.mission_id
		return

	status_label.text = "Dosah: %s (%s)" % [context.name, context.type]
	
	match context.type:
		"door":
			btn_open.disabled = false
			add_log("💡 Dveře v dosahu (OTEVŘÍT)")
		"door_locked":
			btn_pick.disabled = false
			add_log("💡 Zamčené dveře (PÁČIT)")
		"safe":
			btn_use.text = "PROLOMIT"
			btn_use.disabled = false
			add_log("💡 Trezor (PROLOMIT)")
		"alarm_panel":
			btn_use.text = "VYPNOUT"
			btn_use.disabled = false
			add_log("💡 Alarm (VYPNOUT)")
			
func _add_interact_action(action_type: String):
	if not active_character_data or not planning_manager: return
	if _current_context_obj == null: return
	
	var duration = 3.0 # Default
	if action_type == "PICK": duration = 5.0
	elif action_type == "OPEN": duration = 1.0
	
	# Add to plan
	var plan = planning_manager.current_plan.get_or_create_plan_for(active_character_data)
	var time = 0.0
	if not plan.actions.is_empty():
		var last = plan.actions.back()
		time = last.time + last.duration
	
	var action = PlanningData.TimelineAction.new()
	action.time = time
	action.type = action_type # START_INTERACT?
	action.duration = duration
	action.target_id = str(_current_context_obj.grid_pos) # Simplistic ID
	
	plan.actions.append(action)
	
	# Add Holding Waypoint (Character is busy interacting)
	var pos = Vector2.ZERO
	if not plan.waypoints.is_empty():
		pos = plan.waypoints.back().position
		
	var holding_wp = PlanningData.TimelineWaypoint.new()
	holding_wp.position = pos
	holding_wp.time = time + duration
	holding_wp.speed = 0.0
	plan.waypoints.append(holding_wp)
	
	add_log("%s: %s na %s (%.1fs)" % [active_character_data.name, action_type, _current_context_obj.name, duration])
	planning_manager.plan_updated.emit()


func _zoom_map(amount: float):
	var scale_factor = map_canvas.scale.x + amount
	scale_factor = clamp(scale_factor, 0.5, 2.0)
	map_canvas.scale = Vector2(scale_factor, scale_factor)

func _cycle_character_selection():
	if not planning_manager: return
	var current_idx = planning_manager.team.find(active_character_data)
	var next_idx = (current_idx + 1) % planning_manager.team.size()
	planning_manager.select_character(next_idx)

func _try_select_character(_mouse_pos: Vector2):
	if not planning_manager: return
	
	var local_pos = entities_layer.get_local_mouse_position()
	
	for char_data in character_sprites:
		var sprite = character_sprites[char_data]
		if sprite.position.distance_to(local_pos) < 30:
			# Find index
			var idx = planning_manager.team.find(char_data)
			if idx != -1:
				planning_manager.select_character(idx)
				is_dragging = true
				temp_path_points.clear()
				temp_path_points.append(sprite.position)
				return

func _end_drag():
	is_dragging = false
	if active_character_data and temp_path_points.size() > 1:
		# Recording new movement via GhostController or manual action addition
		# Since we are in the main view, we might want to tell the PlanningManager 
		# that we recorded a path.
		# For now, we will add a MOVE action manually to the data since GhostController might be complex to invoke from here directly without recording mode.
		# However, PlanningManager has 'ghost_controller' we could hypothetically use.
		# Let's stick to modifying data for simplicity in this step, or use a helper if available.
		# Simplification: Calculate duration and add action
		var dist = 0.0
		for i in range(1, temp_path_points.size()):
			dist += temp_path_points[i - 1].distance_to(temp_path_points[i])
			
		var duration = dist / 150.0
		
		# We need to add this to the plan via PlanningManager to ensure consistency
		# But PlanningManager doesn't have a direct "add_move_path" method exposed in the snippet we saw.
		# It has 'start_recording_current' and 'commit'.
		# Let's bypass for now and edit PlanningData directly, then emit update.
		
		var plan = planning_manager.current_plan.get_or_create_plan_for(active_character_data)
		var new_action = PlanningData.TimelineAction.new()
		new_action.time = plan.actions.back().time + plan.actions.back().duration if not plan.actions.is_empty() else 0.0
		new_action.type = "MOVE"
		new_action.duration = duration
		# We need to store points somewhere. The current TimelineAction definition in snippet 
		# didn't explicitly show a 'points' field, but it checked "points" in the mock.
		# Let's check PlanningData.gd again... it had TimelineWaypoint but Action was generic.
		# Ah, the Waypoints are separate in CharacterPlan!
		# We should be adding WAYPOINTS for movement, not just ACTIONS.
		
		# Adding waypoints
		var start_time = new_action.time
		var time_per_dist = duration / dist if dist > 0 else 0.0
		var current_dist = 0.0
		
		for p in temp_path_points:
			var wp = PlanningData.TimelineWaypoint.new()
			wp.position = p
			# Estimate time for this point
			# accurate distance calculation needed
			if temp_path_points.find(p) > 0:
				var prev = temp_path_points[temp_path_points.find(p) - 1]
				current_dist += prev.distance_to(p)
			
			wp.time = start_time + (current_dist * time_per_dist)
			plan.waypoints.append(wp)
			
		# Add Action to represent the block in timeline
		plan.actions.append(new_action)
		
		add_log("Přidán pohyb pro " + active_character_data.name + " (%.1fs)" % duration)
		
		# Update visuals
		var sprite = character_sprites[active_character_data]
		if not temp_path_points.is_empty():
			sprite.position = temp_path_points[temp_path_points.size() - 1]
		
		planning_manager.plan_updated.emit()
		_update_timeline_max()
	
	temp_path_points.clear()
	_clear_ghost_lines()

func _update_timeline_max():
	if not planning_manager or not planning_manager.current_plan: return
	
	# Calculate actual max based on actions
	var calculated_max = 0.0
	for char_name in planning_manager.current_plan.character_plans:
		var plan = planning_manager.current_plan.character_plans[char_name]
		if not plan.actions.is_empty():
			var last = plan.actions.back()
			calculated_max = max(calculated_max, last.time + last.duration)
			
	timeline_slider.max_value = max(180.0, calculated_max + 10.0)
	status_label.text = "Plánování: %s | Celkový čas: %.1fs" % [planning_manager.current_plan.mission_id, calculated_max]

func _on_plan_updated():
	_update_timeline_max()
	_draw_action_markers()
	
func _draw_action_markers():
	# Clear old markers (only labels, assume route lines are managed separately or reuse structure)
	for child in route_lines_layer.get_children():
		if child is Label or child is TextureRect:
			child.queue_free()
			
	if not planning_manager or not planning_manager.current_plan: return
	
	for char_name in planning_manager.current_plan.character_plans:
		var plan = planning_manager.current_plan.character_plans[char_name]
		for action in plan.actions:
			if action.type == "MOVE": continue # Skip moves
			
			var pos = plan.get_position_at_time(action.time)
			var marker = Label.new()
			marker.text = action.type
			# Simplify text
			if action.type == "CRACK_SAFE": marker.text = "PROLOMIT"
			elif action.type == "CUT_WIRE": marker.text = "VYPNOUT"
			elif action.type == "PICK": marker.text = "PÁČIT"
			elif action.type == "WAIT": marker.text = "ČEKAT " + str(action.duration) + "s"
			
			marker.position = pos + Vector2(-20, -20)
			marker.add_theme_font_size_override("font_size", 10)
			marker.add_theme_color_override("font_color", Color(1, 1, 0))
			if action.type == "WAIT":
				marker.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
				
			route_lines_layer.add_child(marker)
	
func _update_ghost_trail():
	_clear_ghost_lines()
	var line = Line2D.new()
	line.name = "Ghost"
	line.width = 2.0
	line.default_color = Color(0.3, 0.7, 1.0, 0.6)
	line.points = temp_path_points
	
	ghost_lines_layer.add_child(line)

func _on_timeline_changed(value: float):
	status_label.text = "Náhled: %.1fs" % value
	if not planning_manager: return
	
	for char_data in character_sprites:
		var plan = planning_manager.current_plan.get_or_create_plan_for(char_data)
		if plan:
			var pos = plan.get_position_at_time(value)
			character_sprites[char_data].position = pos


func _clear_ghost_lines():
	for child in ghost_lines_layer.get_children():
		child.queue_free()

func add_log(msg: String):
	var l = Label.new()
	l.text = "> " + msg
	l.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	l.add_theme_font_size_override("font_size", 14)
	log_container.add_child(l)
	log_container.move_child(l, 0)
	
	if log_container.get_child_count() > 20:
		log_container.get_child(log_container.get_child_count() - 1).queue_free()

func _show_context_menu(screen_pos: Vector2):
	add_log("Pravé tlačítko: Akce pro objekt na " + str(screen_pos))
	# Zde by se otevíralo ContextMenu.tscn


func _update_ui_state():
	# Nastavení barev pro panely (Glassmorphism je v TSCN přes ColorRect s alfa kanálem)
	# Zde můžeme přidat dynamické stylování slideru
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.3, 0.6, 1.0, 0.8)
	sb.expand_margin_top = 2
	sb.expand_margin_bottom = 2
	timeline_slider.add_theme_stylebox_override("grabber_area", sb)
	timeline_slider.add_theme_stylebox_override("grabber_area_highlight", sb)

# --- Obsluha simulace ---

func _on_BtnSimulate_pressed():
	if simulation_running: return
	if not planning_manager: return
	
	simulation_running = true
	add_log("📽️ Spouštím synchronizovanou simulaci týmu...")
	
	# Reset pozic na začátek simulace
	for char_data in character_sprites:
		var plan = planning_manager.current_plan.get_or_create_plan_for(char_data)
		if not plan.waypoints.is_empty():
			character_sprites[char_data].position = plan.waypoints[0].position
		else:
			# Fallback if no path (should be at entry point)
			pass
			
	var master_tween = create_tween()
	master_tween.set_parallel(true)
	
	var max_duration = planning_manager.current_plan.timeline_duration
	# Or calculate from actual actions end
	var actual_max_time = 0.0
	
	# We will animate simply by "scrubbing" the timeline from 0 to MAX with a tween
	# This ensures we reuse the same logic as the slider preview
	var duration = max_duration # Realtime (1s in game = 1s in sim)
	
	# Find real end of actions to not wait for full 10 mins if plan is short
	for char_name in planning_manager.current_plan.character_plans:
		var plan = planning_manager.current_plan.character_plans[char_name]
		if not plan.actions.is_empty():
			var last = plan.actions.back()
			actual_max_time = max(actual_max_time, last.time + last.duration)
	
	duration = max(5.0, actual_max_time)
	
	# Simulation Speed (2x requested)
	var sim_actual_duration = duration / 2.0
	
	timeline_slider.value = 0
	master_tween.tween_method(func(val):
		_on_timeline_changed(val)
		timeline_slider.value = val # Sync slider visualization
	, 0.0, duration, sim_actual_duration)
	
	master_tween.chain().tween_callback(func():
		simulation_running = false
		add_log("✅ Simulace dokončena.")
	)

func _on_BtnWalk_pressed():
	# V reálné aplikaci by toto přepnulo režim kurzoru na "Chůze"
	add_log("🚶 Vybrán režim chůze")

func _on_BtnExecute_pressed():
	if planning_manager and planning_manager.get_final_plan():
		emit_signal("planning_completed", planning_manager.current_plan)
		add_log("🕶️ Provádím plán!")
	else:
		add_log("❌ Nelze provést: Plán není validní.")

func _on_BtnSave_pressed():
	# TODO: Implement serialization in PlanningData
	add_log("💾 Ukládání není zatím implementováno pro nová data.")

func _on_BtnWait_pressed():
	if not active_character_data or not planning_manager: return
	
	var duration = 5.0
	var plan = planning_manager.current_plan.get_or_create_plan_for(active_character_data)
	
	# Determite start time based on last waypoint
	var start_time = 0.0
	var pos = Vector2.ZERO
	if not plan.waypoints.is_empty():
		var last_wp = plan.waypoints.back()
		start_time = last_wp.time
		pos = last_wp.position
	
	# 1. Add WAIT Action
	planning_manager.add_wait_action(active_character_data, start_time, duration)
	
	# 2. Add Holding Waypoint (Stay in place)
	var holding_wp = PlanningData.TimelineWaypoint.new()
	holding_wp.position = pos
	holding_wp.time = start_time + duration
	holding_wp.speed = 0.0
	plan.waypoints.append(holding_wp)
	
	add_log(active_character_data.name + ": ⏳ Čeká %.1f sekund" % duration)
	planning_manager.plan_updated.emit()

func _on_BtnInspect_pressed():
	add_log("🔍 Prozkoumávám objekt... Žádné stopy alarmu nenalezeny.")

func _on_BtnUse_pressed():
	if active_character_data:
		# Use the dynamic label of the button to determine action type or fallback to USE
		var actions = bottom_menu.find_child("ActionsContainer", true, false)
		var btn_text = "USE"
		if actions:
			btn_text = actions.get_node("BtnUse").text
		
		# Map button text to action type
		var type = "USE"
		if "PROLOMIT" in btn_text: type = "CRACK_SAFE"
		elif "VYPNOUT" in btn_text: type = "CUT_WIRE"
		
		_add_interact_action(type)

func _on_BtnGuard_pressed():
	add_log("👮 Zobrazení tras stráží: Hlídka u vily má 15s cyklus.")
