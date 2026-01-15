extends Node2D

@export var is_active: bool = true
@export var scan_speed: float = 1.0
@export var scan_angle: float = 90.0
@export var rotation_offset: float = 0.0

@onready var vision_cone = $VisionCone

var _initial_rotation: float
var _time: float = 0.0

func _ready():
	_initial_rotation = rotation
	if has_node("VisionCone"):
		vision_cone.detection_event.connect(_on_player_detected)
	
	# Listen for security shutdown
	EventBus.security_shutdown_requested.connect(func(_source): deactivate())
	add_to_group("security_cameras")

func _process(delta):
	if not is_active:
		if vision_cone: vision_cone.visible = false
		return
		
	_time += delta * scan_speed
	var angle_offset = sin(_time) * deg_to_rad(scan_angle / 2.0)
	rotation = _initial_rotation + angle_offset

func _on_player_detected(player):
	if is_active:
		print("CAMERA: Player detected! Triggering alarm.")
		EventBus.player_spotted.emit(player)

func deactivate():
	is_active = false
	if vision_cone:
		vision_cone.set_deferred("monitoring", false)
		vision_cone.visible = false
	print("CAMERA: Deactivated.")
