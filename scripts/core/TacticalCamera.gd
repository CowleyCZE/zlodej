class_name TacticalCamera
extends Camera2D

# TacticalCamera.gd
# Sleduje cíl (hráče) s možností manuálního posunu (panning)

@export var target: Node2D
@export var smooth_speed: float = 5.0
@export var drag_speed: float = 1.0

var drag_offset: Vector2 = Vector2.ZERO
var is_dragging: bool = false
var last_drag_pos: Vector2 = Vector2.ZERO

func _ready():
	make_current()
	position_smoothing_enabled = true
	position_smoothing_speed = smooth_speed

func _physics_process(delta):
	if target:
		# Základní pozice je target + manuální offset
		var desired_pos = target.global_position + drag_offset
		position = position.lerp(desired_pos, smooth_speed * delta)

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				last_drag_pos = event.position
			else:
				is_dragging = false
	
	elif event is InputEventMouseMotion and is_dragging:
		var delta_drag = event.position - last_drag_pos
		last_drag_pos = event.position
		
		# Posouváme offset PROTI směru tahu (jako Google Maps)
		drag_offset -= delta_drag * drag_speed

func reset_offset():
	var tween = create_tween()
	tween.tween_property(self, "drag_offset", Vector2.ZERO, 0.5).set_trans(Tween.TRANS_CUBIC)
