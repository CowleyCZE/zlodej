extends Node

var completed_missions = []
var unlocked_missions = []

signal mission_unlocked(mission_id)

func unlock_mission(mission_id):
	if not mission_id in unlocked_missions:
		unlocked_missions.append(mission_id)
		mission_unlocked.emit(mission_id)
		SaveManager.save_game()

func complete_mission(mission_id):
	if not mission_id in completed_missions:
		completed_missions.append(mission_id)
		SaveManager.save_game()
		EventBus.emit_signal("mission_completed", mission_id)
