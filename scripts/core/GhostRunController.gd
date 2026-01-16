# GhostRunController.gd
extends Node

class_name GhostRunController

# Signály pro komunikaci s MainScene
signal recording_started(char_id)
signal recording_stopped(char_id)
signal recording_committed(char_id, track_data)
signal time_updated(current_time)

var is_recording: bool = false
var active_char_id: String
var current_time: float = 0.0
var active_track: Array[Dictionary] = []

# Uložené a potvrzené trasy pro všechny postavy
var committed_tracks: Dictionary = {} # např. {"josef": [{"time": 0.1, "pos": Vector2(...)}], ...}

# Odkazy na "duchy" (Node2D instance)
var ghost_nodes: Dictionary = {} # {"petra": Node2D_instance, ...}

func _physics_process(delta: float):
	if is_recording:
		current_time += delta
		# _record_frame() # Nyní voláno z PlayerAgent.gd přímo přes record_frame()
		_replay_ghosts()
		time_updated.emit(current_time)

# --- Veřejné metody pro ovládání z MainScene ---

func record_frame(pos: Vector2, vel: Vector2, actions: Dictionary = {}):
	if not is_recording:
		return
		
	var frame_data = {
		"time": current_time,
		"pos": pos,
		"vel": vel,
		"actions": actions
	}
	active_track.append(frame_data)

func start_recording(char_id: String):
	if is_recording:
		printerr("Nelze spustit nahrávání, již jedno běží.")
		return
		
	print("GhostRunController: Spuštěno nahrávání pro ", char_id)
	active_char_id = char_id
	is_recording = true
	current_time = 0.0
	active_track.clear()
	recording_started.emit(char_id)

func stop_recording():
	if not is_recording:
		return
		
	print("GhostRunController: Zastaveno nahrávání pro ", active_char_id)
	is_recording = false
	recording_stopped.emit(active_char_id)

func commit_recording():
	if active_track.is_empty():
		printerr("Nelze uložit prázdnou trasu.")
		return
	
	print("GhostRunController: Ukládám trasu pro ", active_char_id)
	var final_track = active_track.duplicate()
	committed_tracks[active_char_id] = final_track
	recording_committed.emit(active_char_id, final_track)
	active_track.clear()
	is_recording = false # Nahrávání končí uložením
	
	# Skryjeme UI
	var main_scene = get_parent()
	if main_scene and main_scene.has_method("_on_recording_stopped"):
		main_scene._on_recording_stopped(active_char_id)


func record_action(action_name: String, target_obj: Object, duration: float = 0.0): # Přidán parametr duration
	if not is_recording:
		return
		
	var action_data = {
		"time": current_time,
		"type": "action",
		"name": action_name,
		"target_id": target_obj.get_instance_id(),
		"duration": duration # Nově ukládáme duration
	}
	active_track.append(action_data)
	print("GhostRunController: Zaznamenána akce '", action_name, "' (", duration, "s) v čase ", current_time)

func set_ghost_nodes(ghosts: Dictionary):
	ghost_nodes = ghosts

# --- Interní logika ---

func _record_frame():
	var main_scene = get_parent() # Předpokládáme, že je dítětem MainScene
	if not main_scene or not main_scene.character_data.has(active_char_id):
		return
		
	var token = main_scene.character_data[active_char_id].token
	if not is_instance_valid(token):
		return
		
	var frame_data = {
		"time": current_time,
		"pos": token.global_position
		# V budoucnu můžeme přidat i rotaci, atd.
	}
	active_track.append(frame_data)

func _replay_ghosts():
	for char_id in committed_tracks:
		if char_id == active_char_id:
			continue # Nepřehráváme ducha pro aktivní postavu
			
		var ghost_node = ghost_nodes.get(char_id, null)
		if not is_instance_valid(ghost_node):
			continue
			
		var track = committed_tracks[char_id]
		var target_pos = _get_position_at_time(track, current_time)
		
		if target_pos:
			ghost_node.global_position = target_pos
			ghost_node.visible = true
		else:
			# Pokud je čas za koncem trasy ducha, necháme ho na konci
			if not track.is_empty():
				ghost_node.global_position = track[-1].pos
			else:
				ghost_node.visible = false


func _get_position_at_time(track: Array, time: float) -> Variant:
	if track.is_empty() or time < track[0].time:
		return null
	
	# Najdeme dva body, mezi kterými se nacházíme
	for i in range(track.size() - 1):
		var p1 = track[i]
		var p2 = track[i+1]
		
		if time >= p1.time and time <= p2.time:
			var t = (time - p1.time) / (p2.time - p1.time)
			return p1.pos.lerp(p2.pos, t)
			
	# Pokud jsme za posledním bodem
	if time > track[-1].time:
		return track[-1].pos
		
	return null
