extends Node

# --- ODKAZY NA UZLY ---
@onready var path_visualizer = $GameWorld/PathVisualizer
@onready var player_token = $GameWorld/PlayerToken
@onready var hacker_token = $GameWorld/HackerToken
@onready var timeline_panel = $CanvasLayer/HUD/TimelinePanel
@onready var control_pad = $CanvasLayer/HUD/ControlPad
@onready var char_selector = $CanvasLayer/HUD/CharacterSelector
@onready var context_menu = $CanvasLayer/ContextMenu

# --- KONFIGURACE ---
const CHARACTER_SPEEDS = {
	"josef": 220.0, # Řidič - rychlý
	"petra": 180.0, # Hacker - průměr
	"milan": 150.0  # Silák - pomalý
}
const CHARACTER_COLORS = {
	"josef": Color("#FF8C42"),
	"petra": Color("#457B9D"),
	"milan": Color("#FF6B6B")
}
const STEP_SIZE: float = 64.0 
const STEP_DURATION: float = 0.5 

var waypoint_scene = preload("res://scenes/objects/Waypoint.tscn")
var active_char_id: String = "josef"
var character_data: Dictionary = {
	"josef": {
		"points": [],
		"actions": {},
		"events": [],
		"token": null,
		"total_time": 0.0
	},
	"petra": {
		"points": [],
		"actions": {},
		"events": [],
		"token": null,
		"total_time": 0.0
	}
}
var total_mission_time: float = 0.0

func _ready():
	print("--- START SYSTEMU ZLODĚJ MĚLNÍK ---")
	
	character_data.josef.token = player_token
	character_data.petra.token = hacker_token
	
	# Barvy podle Art Bible
	player_token.get_node("Sprite2D").modulate = CHARACTER_COLORS.josef
	hacker_token.get_node("Sprite2D").modulate = CHARACTER_COLORS.petra
	
	if context_menu:
		context_menu.mouse_filter = Control.MOUSE_FILTER_STOP
		context_menu.visible = false
	
	# Počáteční pozice
	player_token.position = Vector2(100, 100)
	hacker_token.position = Vector2(100, 180)
	
	# Počáteční body
	character_data.josef.points.append(player_token.position)
	character_data.petra.points.append(hacker_token.position)
	
	timeline_panel.time_scrubbed.connect(_on_timeline_scrub)
	timeline_panel.add_character_track("josef", "Josef (Řidič)")
	timeline_panel.add_character_track("petra", "Petra (Hacker)")
	
	if control_pad:
		control_pad.move_command.connect(_on_control_pad_move)
		control_pad.undo_command.connect(_on_control_pad_undo)
		
	if char_selector:
		if char_selector.is_connected("character_selected", _on_character_selected):
			char_selector.disconnect("character_selected", _on_character_selected)
		char_selector.character_selected.connect(_on_character_selected)
		print("✅ CharacterSelector propojen v MainScene")
	
	context_menu.action_selected.connect(_on_action_selected)
	
	EventBus.player_spotted.connect(_on_player_spotted)
	
	# Automatické propojení objektů
	for child in $GameWorld.get_children():
		if child.has_signal("object_clicked"):
			child.object_clicked.connect(_on_object_clicked)
			
			if "input_pickable" in child:
				child.input_pickable = true
			print("✅ Objekt připojen: ", child.name)

	recalculate_timeline()
	_on_character_selected("josef") # Inicializace vizuálu

func _on_character_selected(char_id: String):
	print("SYSTÉM: Přepínám ovládání na: ", char_id)
	active_char_id = char_id
	
	# Vizuální zvýraznění aktivní postavy
	for id in character_data:
		var token = character_data[id].token
		if token:
			if id == active_char_id:
				token.modulate = Color(1, 1, 1, 1) # Jasná
				token.z_index = 10
			else:
				token.modulate = Color(0.3, 0.3, 0.3, 0.7) # Ztmavená
				token.z_index = 5
	
	refresh_path_visualizer()

func refresh_path_visualizer():
	path_visualizer.clear_points()
	if character_data.has(active_char_id):
		for p in character_data[active_char_id].points:
			path_visualizer.add_point(p)


func _unhandled_input(event):
	# Mouse interactions only for Context Menu handling
	if context_menu.visible:
		if event is InputEventMouseButton and event.pressed:
			if is_mouse_over_menu():
				return 
			else:
				context_menu.close_menu()
				return 
	
	if event is InputEventMouseButton and event.pressed:
		if is_mouse_over_selector():
			return

func is_mouse_over_selector() -> bool:
	if not char_selector: return false
	return char_selector.get_global_rect().has_point(get_viewport().get_mouse_position())

func _on_control_pad_move(direction: Vector2):
	var data = character_data[active_char_id]
	var current_pos = data.token.position
	var target_pos = current_pos + (direction * STEP_SIZE)
	
	# Check collision using move_and_collide logic (simulated)
	var space_state = $GameWorld.get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(current_pos, target_pos)
	query.collision_mask = 1 # Walls
	var result = space_state.intersect_ray(query)
	
	if result:
		print("Hit wall!")
		return
		
	# Check interactive objects at target
	var query_point = PhysicsPointQueryParameters2D.new()
	query_point.position = target_pos
	query_point.collide_with_areas = true 
	query_point.collide_with_bodies = true
	var results_point = space_state.intersect_point(query_point)
	
	var blocked_by_interaction = false
	for item in results_point:
		if item["collider"].is_in_group("interactive"):
			var obj = item["collider"]
			print("Interaction at step: ", obj.object_name)
			if obj.has_method("_get_available_actions"):
				var actions = obj._get_available_actions()
				if not actions.is_empty():
					context_menu.open_menu(get_viewport().get_visible_rect().size / 2, actions, obj)
					context_menu.visible = true
					blocked_by_interaction = true
	
	if not blocked_by_interaction:
		data.token.position = target_pos
		data.points.append(target_pos)
		path_visualizer.add_point(target_pos)
		recalculate_timeline()

func _on_control_pad_undo():
	var data = character_data[active_char_id]
	if data.points.size() > 1:
		data.points.remove_at(data.points.size() - 1)
		refresh_path_visualizer()
		data.token.position = data.points[-1]
		recalculate_timeline()

func is_mouse_over_interactive_object() -> bool:
	var space_state = $GameWorld.get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = get_viewport().get_mouse_position()
	query.collide_with_areas = true
	query.collide_with_bodies = true
	var result = space_state.intersect_point(query)
	for item in result:
		if item["collider"].is_in_group("interactive"):
			return true
	return false

func is_mouse_over_menu() -> bool:
	if not context_menu.visible: return false
	return context_menu.get_global_rect().has_point(get_viewport().get_mouse_position())

func _on_object_clicked(obj, actions):
	var data = character_data[active_char_id]
	var current_pos = data.token.position
	var dist = current_pos.distance_to(obj.position)
	
	if dist > 100.0:
		print("SYSTÉM: ", active_char_id, " je příliš daleko od ", obj.object_name, " (", int(dist), "px)")
		return

	print("!!! SIGNÁL DORAZIL: ", obj.object_name)
	var menu_pos = get_viewport().get_mouse_position() + Vector2(10, 10)
	context_menu.open_menu(menu_pos, actions, obj)
	context_menu.visible = true
	context_menu.move_to_front()

func _on_action_selected(action_name, target_obj):
	# Získáme data postavy z AdventureManageru pro validaci skillů
	var char_data = null
	for c in AdventureManager.hired_characters:
		var simple_name = "josef" if "Josef" in c.name else "petra"
		if simple_name == active_char_id:
			char_data = c
			break
	
	if action_name == "Páčit":
		if char_data and char_data.lockpicking_skill < 30:
			print("SYSTÉM: ", char_data.name, " nemá dostatečný skill na páčení!")
			return
			
		var diff = target_obj.difficulty if "difficulty" in target_obj else 1.0
		EventBus.request_lockpick_minigame.emit(diff, func(success):
			if success:
				_add_action_to_timeline(action_name, target_obj)
		)
	elif action_name == "Hackovat":
		if char_data and char_data.electronics_skill < 30:
			print("SYSTÉM: ", char_data.name, " nerozumí této elektronice!")
			return
			
		var diff = target_obj.difficulty if "difficulty" in target_obj else 1.0
		EventBus.request_hacking_minigame.emit(diff, func(success):
			if success:
				_add_action_to_timeline(action_name, target_obj)
		)
	else:
		_add_action_to_timeline(action_name, target_obj)

func _add_action_to_timeline(action_name, target_obj):
	if target_obj.has_method("_on_action_selected"):
		target_obj._on_action_selected(action_name)
		
	var duration = get_action_duration(action_name)
	var closest_index = find_closest_path_index(target_obj.position)
	if closest_index != -1:
		character_data[active_char_id].actions[closest_index] = { "duration": duration, "name": action_name, "obj": target_obj }
		var wp_pos = character_data[active_char_id].points[closest_index]
		spawn_waypoint(wp_pos, action_name, duration)
		recalculate_timeline()

func find_closest_path_index(target_pos: Vector2) -> int:
	var best_dist = 200.0 
	var best_index = -1
	var points = character_data[active_char_id].points
	if points.size() < 2: return -1
	for i in range(points.size()):
		var dist = points[i].distance_to(target_pos)
		if dist < best_dist:
			best_dist = dist
			best_index = i
	return best_index

func get_action_duration(action_name: String) -> float:
	match action_name:
		"Otevřít": return 1.0
		"Páčit": return 5.0
		"Vrtat": return 8.0
		"Čekat 5s": return 5.0
		_: return 2.0

func get_action_noise(action_name: String) -> float:
	match action_name:
		"Páčit": return 150.0
		"Vrtat": return 300.0
		"Otevřít": return 50.0
		_: return 0.0

func spawn_waypoint(pos: Vector2, text: String, duration: float):
	var wp = waypoint_scene.instantiate()
	$GameWorld.add_child(wp)
	var label_text = "%s\n(%.1fs)" % [text, duration]
	if wp.has_method("setup"): wp.setup(pos, 0.0, 0.0)
	if wp.has_node("TimeLabel"): wp.get_node("TimeLabel").text = label_text

func recalculate_timeline():
	total_mission_time = 0.0
	
	for char_id in character_data:
		var data = character_data[char_id]
		data.events.clear()
		timeline_panel.clear_track_actions(char_id)
		
		var char_time = 0.0
		if data.points.size() < 1: continue
		
		var char_speed = CHARACTER_SPEEDS.get(char_id, 200.0)
		
		for i in range(data.points.size() - 1):
			var p1 = data.points[i]
			var p2 = data.points[i+1]
			var move_dur = STEP_SIZE / char_speed
			data.events.append({ "type": "move", "start": char_time, "end": char_time + move_dur, "dur": move_dur, "p1": p1, "p2": p2 })
			char_time += move_dur
			
			var point_idx = i + 1
			if data.actions.has(point_idx):
				var action_data = data.actions[point_idx]
				var wait_dur = action_data.duration
				data.events.append({ 
					"type": "wait", 
					"start": char_time, 
					"end": char_time + wait_dur, 
					"dur": wait_dur, 
					"pos": p2,
					"action_name": action_data.name,
					"target_obj": action_data.obj
				})
				char_time += wait_dur
		
		data.total_time = char_time
		total_mission_time = max(total_mission_time, char_time)
			
	# Update markers on timeline tracks
	if total_mission_time > 0:
		for char_id in character_data:
			var data = character_data[char_id]
			for event in data.events:
				if event.type == "wait":
					var start_ratio = event.start / total_mission_time
					var dur_ratio = event.dur / total_mission_time
					timeline_panel.add_action_to_track(char_id, start_ratio, dur_ratio)
	
	timeline_panel.update_time_display(0.0, total_mission_time)
	print("Timeline OK. Celkový čas mise: ", total_mission_time)

func _on_timeline_scrub(value: float):
	if total_mission_time <= 0.0: return
	var current_t = value * total_mission_time
	timeline_panel.update_time_display(current_t, total_mission_time)
	
	# Update Guards and other timeline listeners
	get_tree().call_group("timeline_listeners", "set_timeline_time", current_t)
	
	for char_id in character_data:
		var data = character_data[char_id]
		var found_event = false
		
		# Check for completed actions first
		for event in data.events:
			if event.type == "wait" and event.has("target_obj") and is_instance_valid(event.target_obj):
				if current_t >= event.end:
					if event.target_obj.has_method("on_timeline_action_completed"):
						event.target_obj.on_timeline_action_completed(event.action_name)
						
					# Vizuální hluk (Ripples)
					var noise_radius = get_action_noise(event.action_name)
					if noise_radius > 0:
						# Vyvoláme hluk pouze pokud jsme v "Heist" nebo Planning simulaci
						NoiseSystem.emit_noise(event.pos, noise_radius)
		
		# Update positions
		for event in data.events:
			if current_t >= event.start and current_t <= event.end:
				if event.type == "move":
					var t = (current_t - event.start) / event.dur
					data.token.position = event.p1.lerp(event.p2, t)
					if event.p1 != event.p2: data.token.rotation = (event.p2 - event.p1).angle()
				elif event.type == "wait":
					data.token.position = event.pos
				found_event = true
				break
		
		# If time is past all events for this char, stay at last point
		if not found_event and not data.points.is_empty():
			data.token.position = data.points[-1]
			
	check_for_extraction()


func _on_player_spotted(_body):
	if GameManager.current_state == GameManager.GameState.HEIST:
		print("MISSION FAILED: Spotted by guard!")
		show_result_screen(false)
	else:
		# In Planning Mode, maybe just a notification or warning on timeline
		print("WARNING: Guard can see you at this time!")

func check_for_extraction():
	for zone in get_tree().get_nodes_in_group("extraction_zone"):
		if zone.check_extraction(player_token.position):
			if GameManager.main_loot_collected:
				show_result_screen(true)

func show_result_screen(success: bool):
	# Zamezíme vícenásobnému zobrazení
	if $CanvasLayer.has_node("ResultScreen"): return
	
	var res_packed = load("res://scenes/ui/ResultScreen.tscn")
	var res = res_packed.instantiate()
	$CanvasLayer.add_child(res)
	
	var title = res.get_node("VBoxContainer/Title")
	if title:
		title.text = "MISE ÚSPĚŠNÁ" if success else "MISE SE NEZDAŘILA"
		title.modulate = Color.GREEN if success else Color.RED
		
	var loot_info = res.get_node("VBoxContainer/LootInfo")
	if loot_info:
		if success:
			loot_info.text = "Získáno: %d CZK" % GameManager.current_mission_loot
		else:
			loot_info.text = "Byl jsi dopaden strážemi!"
			
	res.get_node("VBoxContainer/Btn_ReturnToMap").pressed.connect(_on_return_to_map_pressed)

func _on_return_to_map_pressed():
	# Návrat do stavu Adventure (mapa)
	var game = get_tree().root.find_child("Game", true, false)
	if game:
		game.set_state(GameManager.GameState.ADVENTURE)
