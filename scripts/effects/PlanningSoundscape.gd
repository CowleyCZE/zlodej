class_name PlanningSoundscape
extends Node

var _last_beep_time: float = 0.0
var _next_beep_delay: float = 5.0

func _ready():
	# Start ambient hum
	AudioManager.start_ambient("amb_blueprint")
	_randomize_beep()

func _process(delta: float):
	_last_beep_time += delta
	if _last_beep_time >= _next_beep_delay:
		_play_system_beep()
		_randomize_beep()

func _play_system_beep():
	# Short technical beep
	AudioManager.play_ui_sound("typewriter", -15.0, randf_range(1.5, 2.0))
	_last_beep_time = 0.0

func _randomize_beep():
	_next_beep_delay = randf_range(3.0, 12.0)

func _exit_tree():
	# Stop blueprint ambient when leaving planning mode
	AudioManager.stop_ambient(0.5)
