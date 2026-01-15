extends Control

# DetectionIndicator.gd
# Shows direction of threat (Guard)

var target: Node2D # The guard
var player: Node2D # The player
var radius: float = 200.0

@onready var arrow = $Arrow

func setup(guard_node, player_node):
	target = guard_node
	player = player_node

func _process(delta):
	if not target or not player:
		queue_free()
		return
		
	# Visibility Check
	var is_alerted = false
	if target.get("alert_meter"):
		is_alerted = target.alert_meter > 0 or target.current_ai_state != target.AIState.PATROL
		
	if not is_alerted:
		visible = false
		return
	
	visible = true
	
	# Direction Logic
	var to_target = target.global_position - player.global_position
	# ... rest of logic ...
	
	# Only show if off-screen or far away
	# ...
	
	# Rotate arrow
	arrow.rotation = to_target.angle()
	
	# Position on screen edge
	var screen_rect = get_viewport_rect()
	var screen_center = screen_rect.size / 2.0
	
	# Clamp to ellipse
	var rx = screen_center.x - 50
	var ry = screen_center.y - 50
	var angle = to_target.angle()
	
	position = screen_center + Vector2(cos(angle) * rx, sin(angle) * ry)
	
	# Color based on state
	if target.current_ai_state == target.AIState.ALERT:
		arrow.color = Color.RED
		modulate.a = 1.0 + sin(Time.get_ticks_msec() * 0.02) * 0.2 # Pulse
	else:
		arrow.color = Color.ORANGE
		modulate.a = 0.8
