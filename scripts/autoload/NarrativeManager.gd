# NarrativeManager.gd (Autoload)
extends Node

var loop_count: int = 0
var knows_about_loop: bool = false

# Narrative Items / Anomalies (persisted)
var anomalies_found: Array[String] = []

signal loop_reset_triggered(count: int)

func _ready():
	# Connect to time manager to watch for midnight resets
	if has_node("/root/TimeManager"):
		get_node("/root/TimeManager").time_changed.connect(_on_time_changed)

func _on_time_changed(new_slot):
	# If we just went from Night to Morning, it's a loop reset
	if new_slot == 0: # TimeManager.TimeSlot.MORNING
		_trigger_loop_reset()

func _trigger_loop_reset():
	loop_count += 1
	if loop_count >= 2:
		knows_about_loop = true
		
	print("NARRATIVE: Loop reset triggered. Current count: ", loop_count)
	
	# Play Eerie Reset Sequence
	AudioManager.play_ui_sound("loop_siren", -2.0)
	
	# Visual Glitch Burst
	if has_node("/root/VFXManager"):
		get_node("/root/VFXManager").trigger_glitch(1.5, 0.8)
	
	get_tree().create_timer(1.0).timeout.connect(func():
		AudioManager.play_ui_sound("glitch_burst", 0.0)
		# Request visual feedback (Game.gd or PostProcess should handle this)
		EventBus.game_state_changed.emit(GameManager.State.MENU) # Return to pub (reset anchor)
	)
	
	loop_reset_triggered.emit(loop_count)

func get_honza_greet() -> String:
	if loop_count == 0:
		return tr("npc_honza_greet_01")
	else:
		return tr("npc_honza_loop_01")

func find_anomaly(id: String):
	if not anomalies_found.has(id):
		anomalies_found.append(id)
		SaveManager.save_game()

# --- Persistence ---
func serialize() -> Dictionary:
	return {
		"loop_count": loop_count,
		"knows_about_loop": knows_about_loop,
		"anomalies": anomalies_found
	}

func deserialize(data: Dictionary):
	if data.has("loop_count"): loop_count = data["loop_count"]
	if data.has("knows_about_loop"): knows_about_loop = data["knows_about_loop"]
	if data.has("anomalies"): anomalies_found = data["anomalies"]
