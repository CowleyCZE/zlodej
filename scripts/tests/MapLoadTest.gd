extends Node

func _ready():
	print("--- STARTING MAP LOAD TEST ---")
	var map_scene = load("res://scenes/levels/WorldMap_2D.tscn")
	if not map_scene:
		print("FAIL: Could not load WorldMap_2D.tscn")
		get_tree().quit(1)
		return
		
	var map = map_scene.instantiate()
	add_child(map)
	print("SUCCESS: Map instantiated.")
	
	# Wait for a frame to let _ready finish
	await get_tree().process_frame
	print("SUCCESS: Map _ready finished.")
	
	# Check for required nodes
	if not map.has_node("UI/SidePanel"):
		print("FAIL: SidePanel missing!")
		get_tree().quit(1)
		return
	
	print("--- MAP LOAD TEST PASSED ---")
	# Keep alive
	while true:
		await get_tree().create_timer(1.0).timeout
