extends Control

@onready var grid = $ScrollContainer/GridContainer

func _ready():
	# Wait for AudioManager to be ready
	await get_tree().process_frame
	
	for key in AudioManager.SFX_LIBRARY:
		var btn = Button.new()
		btn.text = key
		btn.custom_minimum_size = Vector2(250, 50)
		btn.pressed.connect(_on_sound_pressed.bind(key))
		grid.add_child(btn)
	
	# Add Ambience controls
	var stop_amb = Button.new()
	stop_amb.text = "STOP AMBIENCE"
	stop_amb.modulate = Color.RED
	stop_amb.pressed.connect(func(): AudioManager.stop_ambient())
	grid.add_child(stop_amb)

func _on_sound_pressed(key: String):
	print("Playing: " + key)
	if "amb_" in key:
		AudioManager.start_ambient(key)
	elif "phone_ring" in key:
		AudioManager.start_phone_ring()
	elif "step_" in key:
		var parts = key.split("_")
		var surface = parts[1]
		var style = parts[2]
		AudioManager.play_footstep(surface, style)
	else:
		# Detect if tool or UI
		if key in ["phone_pickup", "phone_hangup", "ui_error", "ui_success", "typewriter"]:
			AudioManager.play_ui_sound(key)
		else:
			AudioManager.play_tool_sfx(key)
