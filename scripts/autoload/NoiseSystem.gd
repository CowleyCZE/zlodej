# NoiseSystem.gd (Autoload)
extends Node

signal noise_created(pos: Vector2, radius: float, volume: float)

func emit_noise(pos: Vector2, radius: float = 100.0, volume: float = 1.0):
	noise_created.emit(pos, radius, volume)
	_create_ripple_visual(pos, radius)

func _create_ripple_visual(pos: Vector2, radius: float):
	if radius <= 0: return

	var ripple = Node2D.new()
	ripple.position = pos
	ripple.name = "NoiseRipple"
	
	var parent = get_tree().current_scene
	if parent:
		parent.add_child(ripple)
		
		var debug_circle = Line2D.new()
		debug_circle.points = _get_circle_points(radius)
		debug_circle.width = 2.0
		debug_circle.default_color = Color(1, 1, 0, 0.6)
		ripple.add_child(debug_circle)
		
		# Animate ripple expanding and fading
		debug_circle.scale = Vector2(0.1, 0.1)
		var tween = get_tree().create_tween()
		tween.tween_property(debug_circle, "scale", Vector2(1.0, 1.0), 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(debug_circle, "default_color:a", 0.0, 0.5)
		tween.tween_callback(ripple.queue_free)

func _get_circle_points(radius: float) -> PackedVector2Array:
	var points = PackedVector2Array()
	for i in range(33):
		var angle = i * TAU / 32.0
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	return points
