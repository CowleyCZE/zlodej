# TimeManager.gd (Autoload)
extends Node

enum TimeSlot { DAY, NIGHT }

var current_slot: TimeSlot = TimeSlot.DAY:
	set(value):
		if current_slot != value:
			current_slot = value
			time_changed.emit(current_slot)
			SaveManager.save_game()

signal time_changed(new_slot: TimeSlot)

func advance_time():
	if current_slot == TimeSlot.DAY:
		current_slot = TimeSlot.NIGHT
	else:
		current_slot = TimeSlot.DAY
	print("Time advanced to: ", "NIGHT" if current_slot == TimeSlot.NIGHT else "DAY")

func get_time_string() -> String:
	return "DEN" if current_slot == TimeSlot.DAY else "NOC"

# --- Persistence ---
func serialize() -> Dictionary:
	return {"current_slot": current_slot}

func deserialize(data: Dictionary):
	if data.has("current_slot"):
		current_slot = data["current_slot"]
