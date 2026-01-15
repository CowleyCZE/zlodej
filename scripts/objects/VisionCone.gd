extends Node2D

@export var radius: float = 200.0
@export var angle_deg: float = 60.0
@export var ray_count: int = 30
@export var color: Color = Color(1.0, 0.2, 0.2, 0.3) # Reddish transparent
@export var wall_mask: int = 1 # Collision layer for walls

enum AlertState { IDLE, SUSPICIOUS, ALERT }

const COLOR_IDLE = Color(0.2, 0.4, 1.0, 0.2) # Slabý modrý gloss
const COLOR_SUSPICIOUS = Color(1.0, 0.55, 0.26, 0.5) # Oranžový gloss 50%
const COLOR_ALERT = Color(1.0, 0.42, 0.42, 0.8) # Jasně červený gloss 80%

var current_state = AlertState.IDLE
var is_disabled: bool = false
var disable_timer: Timer

@onready var polygon_2d = $Polygon2D
@onready var area_2d = $Area2D
@onready var collision_polygon_2d = $Area2D/CollisionPolygon2D
@onready var line_2d = $Line2D

func _ready():
	add_to_group("electronics") # For EMP interaction
	add_to_group("vision_cones")
	
	# Initialize visuals
	set_alert_level(AlertState.IDLE)
	if line_2d:
		line_2d.width = 2.0
		
	disable_timer = Timer.new()
	disable_timer.one_shot = true
	disable_timer.timeout.connect(_on_disable_timeout)
	add_child(disable_timer)

func disable_temporarily(duration: float):
	is_disabled = true
	disable_timer.start(duration)
	
	# Visual feedback for disabled state
	if polygon_2d: polygon_2d.visible = false
	if line_2d: line_2d.visible = false
	if area_2d: area_2d.monitoring = false
	
	print("VisionCone disabled for ", duration, "s")

func _on_disable_timeout():
	is_disabled = false
	if polygon_2d: polygon_2d.visible = true
	if line_2d: line_2d.visible = true
	if area_2d: area_2d.monitoring = true
	print("VisionCone re-enabled")

func set_alert_level(state: AlertState):
	current_state = state
	var target_color = COLOR_IDLE
	
	match state:
		AlertState.IDLE: target_color = COLOR_IDLE
		AlertState.SUSPICIOUS: target_color = COLOR_SUSPICIOUS
		AlertState.ALERT: target_color = COLOR_ALERT
	
	if polygon_2d:
		polygon_2d.color = target_color
		# Pokud bychom měli shader, nastavovali bychom uniformu
		# polygon_2d.material.set_shader_parameter("cone_color", target_color)
	if line_2d:
		line_2d.default_color = target_color.lightened(0.3)

func _physics_process(_delta):
	update_vision_shape()

func update_vision_shape():
	var points = PackedVector2Array()
	points.append(Vector2.ZERO)
	
	var start_angle = -deg_to_rad(angle_deg) / 2.0
	var angle_step = deg_to_rad(angle_deg) / (ray_count - 1)
	
	var space_state = get_world_2d().direct_space_state
	
	for i in range(ray_count):
		var current_angle = start_angle + (i * angle_step)
		var direction = Vector2.from_angle(rotation + current_angle)
		var target_pos = global_position + direction * radius
		
		var query = PhysicsRayQueryParameters2D.create(global_position, target_pos)
		query.collision_mask = wall_mask
		query.exclude = [] # Add self or guard if needed
		
		var result = space_state.intersect_ray(query)
		
		if result:
			points.append(to_local(result.position))
		else:
			points.append(to_local(target_pos))
			
	# Close the polygon
	# points.append(Vector2.ZERO) # Not strictly needed for Polygon2D if we handle it right, but good for closing
	
	if polygon_2d:
		polygon_2d.polygon = points
		
	if collision_polygon_2d:
		collision_polygon_2d.polygon = points
		
	if line_2d:
		line_2d.points = points
		line_2d.add_point(Vector2.ZERO) # Close the loop visually

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("Player spotted!")
		# Here we would trigger the 'Spotted' state or game over
		EventBus.player_spotted.emit(body)
		
		# Notify parent (Guard) to switch visual state
		var parent = get_parent()
		if parent.has_method("set_alert_state"):
			parent.set_alert_state(AlertState.ALERT)

func is_point_in_cone(target_pos: Vector2) -> bool:
	if is_disabled: return false
	
	var to_target = target_pos - global_position
	var dist_sq = to_target.length_squared()
	
	# 1. Quick distance check
	if dist_sq > radius * radius:
		return false
	
	# 2. Angle check
	var angle_to_target = abs(Vector2.from_angle(global_rotation).angle_to(to_target))
	if angle_to_target > deg_to_rad(angle_deg) / 2.0:
		return false
		
	# 3. Raycast check (occlusion)
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, target_pos)
	query.collision_mask = wall_mask
	
	var result = space_state.intersect_ray(query)
	if result:
		# If we hit something before the target, it's occluded
		# result.position is global, target_pos is global
		if result.position.distance_to(global_position) < target_pos.distance_to(global_position) - 5.0:
			return false
			
	return true
