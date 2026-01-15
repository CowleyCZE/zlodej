extends Control

signal finished

func _ready():
	# Simulate animation and preloading
	await get_tree().create_timer(3.0).timeout # Wait for 3 seconds
	emit_signal("finished")
