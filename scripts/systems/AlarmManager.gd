extends Node

# AlarmManager.gd
# Manages global alert state and coordinates alarm responses

signal alarm_triggered(location: Vector2)
signal alarm_cleared

enum AlarmState { SAFE, SEARCH, LOCKDOWN }
var current_alarm_state: AlarmState = AlarmState.SAFE

# Configuration
const ALARM_DURATION: float = 60.0
var alarm_timer: float = 0.0

func _ready() -> void:
	EventBus.player_spotted.connect(_on_player_spotted)
	add_to_group("alarm_listeners")

func _physics_process(delta: float) -> void:
	if current_alarm_state != AlarmState.SAFE:
		alarm_timer -= delta
		if alarm_timer <= 0:
			clear_alarm()

func trigger_alarm(location: Vector2, duration: float = ALARM_DURATION) -> void:
	if current_alarm_state == AlarmState.LOCKDOWN:
		return
		
	print("ALARM TRIGGERED at ", location)
	current_alarm_state = AlarmState.LOCKDOWN
	alarm_timer = duration
	
	alarm_triggered.emit(location)
	
	# Notify all guards
	get_tree().call_group("guards", "on_global_alarm", location)
	
	# Visual/Audio feedback
	EventBus.heat_level_changed.emit(50.0) # Major heat increase
	
	# Play alarm sound via AudioManager (if implemented)
	# AudioManager.play_sfx("alarm_siren")

func clear_alarm() -> void:
	if current_alarm_state == AlarmState.SAFE:
		return
		
	print("ALARM CLEARED")
	current_alarm_state = AlarmState.SAFE
	alarm_cleared.emit()
	
	get_tree().call_group("guards", "on_alarm_cleared")

func _on_player_spotted(player_node) -> void:
	# Immediate alarm if player is spotted by device or guard
	trigger_alarm(player_node.global_position)
