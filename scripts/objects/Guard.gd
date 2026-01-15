class_name Guard
extends CharacterBody2D

# --- KONFIGURACE ---
@export_group("Movement")
@export var patrol_points: Array[Vector2] = []
@export var walk_speed: float = 100.0
@export var run_speed: float = 180.0
@export var loop_patrol: bool = true
@export var wait_time_at_waypoints: float = 1.0

@export_group("AI Parameters")
@export var detection_speed: float = 50.0 
@export var suspicion_cooldown: float = 5.0 
@export var rotation_speed: float = 5.0

# --- KOMPONENTY ---
@onready var vision_cone = $VisionCone
@onready var sprite = $Sprite2D
@onready var nav_agent: NavigationAgent2D
@onready var awareness_meter = $AwarenessMeter
@onready var awareness_bar = $AwarenessMeter/ProgressBar
@onready var awareness_icon = $AwarenessMeter/StateIcon

# --- STAVOVÉ PROMĚNNÉ ---
enum AIState { PATROL, SUSPICIOUS, SEARCH, ALERT, STUNNED, DEAD }
var current_ai_state: AIState = AIState.PATROL

# Timeline Logic (Planning Mode)
var path_segments: Array = []
var total_distance: float = 0.0
var total_cycle_time: float = 0.0

# Action Logic (Real-time)
var current_patrol_index: int = 0
var patrol_wait_timer: float = 0.0
var suspicion_timer: float = 0.0
var alert_meter: float = 0.0
var investigation_target: Vector2 = Vector2.ZERO
var player_in_sight: Node2D = null

func _ready():
	add_to_group("guards")
	add_to_group("timeline_listeners")
	_recalculate_path_segments()
	
	if not has_node("NavigationAgent2D"):
		var agent = NavigationAgent2D.new()
		agent.path_desired_distance = 10.0
		agent.target_desired_distance = 10.0
		agent.avoidance_enabled = true
		add_child(agent)
		nav_agent = agent
	else:
		nav_agent = $NavigationAgent2D

	var noise_system = get_node_or_null("/root/NoiseSystem")
	if noise_system:
		noise_system.noise_created.connect(_on_noise_heard)

func _physics_process(delta):
	if current_ai_state == AIState.DEAD or current_ai_state == AIState.STUNNED:
		if current_ai_state == AIState.STUNNED:
			_state_stunned(delta)
		return
		
	if GameManager and GameManager.current_state == GameManager.State.PLANNING:
		return
	elif GameManager and GameManager.current_state == GameManager.State.ACTION:
		_process_ai_logic(delta)
	else:
		_check_vision(delta)
		_update_awareness_ui()

func _process_ai_logic(delta):
	_check_vision(delta)
	_update_awareness_ui()
	
	match current_ai_state:
		AIState.PATROL:
			_state_patrol(delta)
		AIState.SUSPICIOUS:
			_state_suspicious(delta)
		AIState.SEARCH:
			_state_search(delta)
		AIState.ALERT:
			_state_alert(delta)

func _update_awareness_ui():
	if not awareness_meter: return
	
	if alert_meter > 0 or current_ai_state != AIState.PATROL:
		awareness_meter.visible = true
		awareness_bar.value = alert_meter
		
		var sb = StyleBoxFlat.new()
		if current_ai_state == AIState.ALERT:
			sb.bg_color = Color.RED
			awareness_icon.color = Color.RED
		elif current_ai_state == AIState.SUSPICIOUS or current_ai_state == AIState.SEARCH:
			sb.bg_color = Color.ORANGE
			awareness_icon.color = Color.ORANGE
		else:
			sb.bg_color = Color.YELLOW
			awareness_icon.color = Color(1, 1, 0, 0)
			
		awareness_bar.add_theme_stylebox_override("fill", sb)
	else:
		awareness_meter.visible = false

# --- TIMELINE LOGIC ---
func set_timeline_time(time: float):
	if path_segments.is_empty(): return
	var current_t = time
	if loop_patrol and total_cycle_time > 0:
		current_t = fmod(time, total_cycle_time)
	elif current_t > total_cycle_time:
		current_t = total_cycle_time
	var dist_traveled = current_t * walk_speed
	for segment in path_segments:
		if dist_traveled >= segment.start_dist and dist_traveled <= segment.end_dist:
			var segment_progress = dist_traveled - segment.start_dist
			global_position = segment.start_pos + (segment.direction * segment_progress)
			rotation = segment.direction.angle()
			break

func _recalculate_path_segments():
	if patrol_points.size() < 2: return
	path_segments.clear()
	total_distance = 0.0
	for i in range(patrol_points.size() - 1):
		_add_segment(patrol_points[i], patrol_points[i+1])
	if loop_patrol:
		_add_segment(patrol_points[-1], patrol_points[0])
	total_cycle_time = total_distance / walk_speed

func _add_segment(p1, p2):
	var dist = p1.distance_to(p2)
	var dir = (p2 - p1).normalized()
	path_segments.append({
		"start_dist": total_distance, "end_dist": total_distance + dist,
		"start_pos": p1, "end_pos": p2, "length": dist, "direction": dir
	})
	total_distance += dist

# --- STEALTH LOGIC ---
func _check_vision(delta):
	if not vision_cone: return
	var bodies = vision_cone.area_2d.get_overlapping_bodies()
	var sees_player = false
	for body in bodies:
		if body.is_in_group("player"):
			var query = PhysicsRayQueryParameters2D.create(global_position, body.global_position)
			query.collision_mask = 1 
			var result = get_world_2d().direct_space_state.intersect_ray(query)
			if not result:
				sees_player = true
				player_in_sight = body
				_escalate_alert(delta)
				break
	if not sees_player:
		player_in_sight = null
		_deescalate_alert(delta)

func _escalate_alert(delta):
	alert_meter += detection_speed * delta
	if alert_meter >= 100.0:
		set_ai_state(AIState.ALERT)
	elif alert_meter > 15.0 and current_ai_state == AIState.PATROL:
		investigation_target = player_in_sight.global_position
		set_ai_state(AIState.SUSPICIOUS)

func _deescalate_alert(delta):
	if alert_meter > 0:
		alert_meter -= (detection_speed * 0.4) * delta
	
	# Only return to patrol if suspicion timer has expired (logic handled in _state_suspicious)
	# But here we prevent overriding logic if meter is empty but timer is running
	if alert_meter <= 0 and current_ai_state == AIState.SUSPICIOUS:
		if suspicion_timer <= 0:
			set_ai_state(AIState.PATROL)

# --- STATES ---
func _state_patrol(delta):
	if vision_cone: vision_cone.set_alert_level(vision_cone.AlertState.IDLE)
	if patrol_points.is_empty(): return
	var target = patrol_points[current_patrol_index]
	if global_position.distance_to(target) < 20.0:
		patrol_wait_timer -= delta
		if patrol_wait_timer <= 0:
			current_patrol_index = (current_patrol_index + 1) % patrol_points.size()
			patrol_wait_timer = wait_time_at_waypoints
	else:
		nav_agent.target_position = target
		_move_towards(nav_agent.get_next_path_position(), walk_speed, delta)

func _state_suspicious(delta):
	if vision_cone: vision_cone.set_alert_level(vision_cone.AlertState.SUSPICIOUS)
	var dir_to_target = (investigation_target - global_position).normalized()
	rotation = lerp_angle(rotation, dir_to_target.angle(), rotation_speed * delta)
	velocity = Vector2.ZERO
	suspicion_timer -= delta
	if suspicion_timer <= 0:
		set_ai_state(AIState.SEARCH)

func _state_search(delta):
	if vision_cone: vision_cone.set_alert_level(vision_cone.AlertState.SUSPICIOUS)
	if global_position.distance_to(investigation_target) > 30.0:
		nav_agent.target_position = investigation_target
		_move_towards(nav_agent.get_next_path_position(), walk_speed * 1.1, delta)
	else:
		suspicion_timer -= delta
		rotation += sin(Time.get_ticks_msec() * 0.005) * 2.0 * delta
		if suspicion_timer <= -4.0:
			set_ai_state(AIState.PATROL)

func _state_alert(delta):
	if vision_cone: vision_cone.set_alert_level(vision_cone.AlertState.ALERT)
	if player_in_sight:
		investigation_target = player_in_sight.global_position
	nav_agent.target_position = investigation_target
	_move_towards(nav_agent.get_next_path_position(), run_speed, delta)
	if not player_in_sight:
		suspicion_timer -= delta
		if suspicion_timer <= -8.0:
			set_ai_state(AIState.SEARCH)

func _move_towards(target_pos, spd, delta):
	var dir = (target_pos - global_position).normalized()
	velocity = dir * spd
	rotation = lerp_angle(rotation, dir.angle(), rotation_speed * delta)
	move_and_slide()

# --- NEW STATES & HIT LOGIC ---

func apply_hit(is_lethal: bool, duration: float = 30.0):
	if current_ai_state == AIState.DEAD: return
	
	if is_lethal:
		set_ai_state(AIState.DEAD)
	else:
		suspicion_timer = duration
		set_ai_state(AIState.STUNNED)

func _state_stunned(delta):
	suspicion_timer -= delta
	if suspicion_timer <= 0:
		set_ai_state(AIState.SEARCH)
		investigation_target = global_position # Start searching where he woke up

func set_ai_state(new_state):
	if current_ai_state == new_state: return
	
	# Cleanup old state
	if current_ai_state == AIState.DEAD: return # Once dead, stay dead
	
	current_ai_state = new_state
	
	match new_state:
		AIState.PATROL:
			if nav_agent: nav_agent.target_position = global_position
			if sprite: sprite.modulate = Color.RED
		AIState.SUSPICIOUS:
			suspicion_timer = 2.0
			if sprite: sprite.modulate = Color.ORANGE
		AIState.SEARCH:
			suspicion_timer = 0.0
			if sprite: sprite.modulate = Color.YELLOW
		AIState.ALERT:
			suspicion_timer = 0.0
			if sprite: sprite.modulate = Color.RED
			GameManager.add_heat(10.0)
		AIState.STUNNED:
			if sprite: sprite.modulate = Color.MEDIUM_SLATE_BLUE
			rotation += PI/2 # Fall over
			if vision_cone: vision_cone.disable_temporarily(suspicion_timer)
			collision_layer = 0 # Can walk over
			EventBus.guard_stunned.emit(self)
			print("Guard STUNNED for ", suspicion_timer, "s")
		AIState.DEAD:
			if sprite: sprite.modulate = Color.DARK_SLATE_GRAY
			rotation += PI/2
			if vision_cone: vision_cone.disable_temporarily(999999)
			collision_layer = 0
			# Heavy Heat penalty for murder
			GameManager.add_heat(25.0)
			EventBus.guard_killed.emit(self)
			print("Guard KILLED. Heat increased.")

	match new_state:
		AIState.PATROL:
			if nav_agent: nav_agent.target_position = global_position

func _on_noise_heard(pos: Vector2, radius: float, _volume: float):
	if current_ai_state == AIState.ALERT: return
	if global_position.distance_to(pos) <= radius:
		investigation_target = pos
		if current_ai_state == AIState.PATROL:
			set_ai_state(AIState.SUSPICIOUS)
		elif current_ai_state == AIState.SUSPICIOUS:
			set_ai_state(AIState.SEARCH)

func on_global_alarm(location: Vector2):
	if current_ai_state == AIState.ALERT: return
	investigation_target = location
	set_ai_state(AIState.ALERT)
	nav_agent.target_position = location

func on_alarm_cleared():
	if current_ai_state == AIState.ALERT:
		set_ai_state(AIState.SEARCH)