extends Node2D

var max_radius: float = 100.0
var current_radius: float = 0.0
var duration: float = 1.0
var elapsed_time: float = 0.0
var color_start: Color = Color(1.0, 1.0, 0.0, 0.6) # Žlutá
var color_end: Color = Color(1.0, 0.0, 0.0, 0.0)   # Červená transparentní

func start(p_radius: float, p_duration: float = 1.0):
	max_radius = p_radius
	duration = p_duration
	queue_redraw()

func _process(delta: float):
	elapsed_time += delta
	var t = elapsed_time / duration
	
	current_radius = lerp(0.0, max_radius, t)
	
	if t >= 1.0:
		queue_free()
	else:
		queue_redraw()

func _draw():
	var t = elapsed_time / duration
	var current_color = color_start.lerp(color_end, t)
	
	# Vykreslíme 3 soustředné kruhy pro lepší efekt
	draw_arc(Vector2.ZERO, current_radius, 0, TAU, 64, current_color, 2.0)
	if current_radius > 20:
		draw_arc(Vector2.ZERO, current_radius - 20, 0, TAU, 64, current_color * 0.5, 1.5)
	if current_radius > 40:
		draw_arc(Vector2.ZERO, current_radius - 40, 0, TAU, 64, current_color * 0.2, 1.0)
