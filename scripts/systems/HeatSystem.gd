# HeatSystem.gd
extends Node

# Tento systém řeší logiku Heat Levelu (hledanosti)
# Primárně se stará o přirozený pokles v čase v Adventure módu

@export var decay_rate: float = 0.5 # Body za minutu v reálném čase
@export var update_interval: float = 5.0 # Každých 5 sekund

var _timer: Timer

func _ready() -> void:
	_timer = Timer.new()
	_timer.wait_time = update_interval
	_timer.autostart = true
	_timer.timeout.connect(_on_timer_timeout)
	add_child(_timer)
	print("HeatSystem: Ready. Decay rate: ", decay_rate, " pts/min")

func _on_timer_timeout() -> void:
	# Heat klesá pouze v Adventure módu
	if GameManager.current_state == GameManager.State.ADVENTURE:
		_process_heat_decay()

func _process_heat_decay() -> void:
	# Výpočet úbytku za interval (decay_rate je za 60s)
	var amount = (decay_rate / 60.0) * update_interval
	
	# Snížíme heat ve všech regionech
	for region in GameManager.heat_levels.keys():
		if GameManager.heat_levels[region] > 0:
			GameManager.add_heat(-amount, region)

func get_heat_description(level: float) -> String:
	if level < 20: return "Klid"
	if level < 50: return "Zvýšená pozornost"
	if level < 80: return "Cílené pátrání"
	return "MAXIMÁLNÍ HEAT"
