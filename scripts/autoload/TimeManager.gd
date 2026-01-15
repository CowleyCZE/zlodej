# TimeManager.gd (Autoload)
extends Node

enum TimeSlot { MORNING, DAY, EVENING, NIGHT }

var current_slot: TimeSlot = TimeSlot.MORNING:
	set(value):
		if current_slot != value:
			current_slot = value
			time_changed.emit(current_slot)
			SaveManager.save_game()

signal time_changed(new_slot: TimeSlot)

func advance_time():
	match current_slot:
		TimeSlot.MORNING: current_slot = TimeSlot.DAY
		TimeSlot.DAY: current_slot = TimeSlot.EVENING
		TimeSlot.EVENING: current_slot = TimeSlot.NIGHT
		TimeSlot.NIGHT: current_slot = TimeSlot.MORNING
	
	print("Time advanced to: ", get_time_string())

func get_time_string() -> String:
	match current_slot:
		TimeSlot.MORNING: return "RÁNO (6-12)"
		TimeSlot.DAY: return "DEN (12-18)"
		TimeSlot.EVENING: return "VEČER (18-24)"
		TimeSlot.NIGHT: return "NOC (0-6)"
	return "NEZNÁMO"

func get_schedule_key() -> String:
	match current_slot:
		TimeSlot.MORNING: return "morning"
		TimeSlot.DAY: return "day"
		TimeSlot.EVENING: return "evening"
		TimeSlot.NIGHT: return "night"
	return "day"

# --- Persistence ---
func serialize() -> Dictionary:
	return {"current_slot": current_slot}

func deserialize(data: Dictionary):
	if data.has("current_slot"):
		current_slot = data["current_slot"]
