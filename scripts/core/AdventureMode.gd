extends Node2D

@onready var level_container = $LevelContainer

func _ready():
	print("AdventureMode.gd: _ready called (2D Mode)")
	# Load level from GameManager
	if GameManager.current_level_path:
		print("AdventureMode.gd: Loading level from GameManager: ", GameManager.current_level_path)
		load_level(GameManager.current_level_path) 
	else:
		print("AdventureMode.gd: No level path in GameManager.")

func load_level(path: String):
	print("AdventureMode.gd: Attempting to load level: ", path)
	if not level_container:
		printerr("AdventureMode.gd: level_container not found!")
		return
		
	for child in level_container.get_children():
		child.queue_free()
	
	var level_packed = load(path)
	if level_packed:
		level_container.add_child(level_packed.instantiate())
		print("AdventureMode.gd: Level instantiated successfully.")
	else:
		printerr("AdventureMode.gd: Failed to load level: ", path)
