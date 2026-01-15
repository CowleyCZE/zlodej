# WeatherManager.gd (Autoload)
extends Node

enum WeatherType { CLEAR, RAIN, FOG }

var current_weather: WeatherType = WeatherType.CLEAR:
	set(value):
		if current_weather != value:
			current_weather = value
			weather_changed.emit(current_weather)
			SaveManager.save_game()

signal weather_changed(new_weather: WeatherType)

func _ready():
	TimeManager.time_changed.connect(_on_time_changed)
	_randomize_weather()

func _on_time_changed(_new_slot):
	# Change weather occasionally when time advances
	if randf() < 0.4:
		_randomize_weather()

func _randomize_weather():
	var roll = randf()
	if roll < 0.6:
		current_weather = WeatherType.CLEAR
	elif roll < 0.9:
		current_weather = WeatherType.RAIN
	else:
		current_weather = WeatherType.FOG
	print("WEATHER: Current conditions are now: ", WeatherType.keys()[current_weather])

func get_weather_string() -> String:
	match current_weather:
		WeatherType.CLEAR: return "JASNO"
		WeatherType.RAIN: return "DEŠTIVO"
		WeatherType.FOG: return "MLHAVO"
	return "NEZNÁMO"

# --- Persistence ---
func serialize() -> Dictionary:
	return {"current_weather": current_weather}

func deserialize(data: Dictionary):
	if data.has("current_weather"):
		current_weather = data["current_weather"]
