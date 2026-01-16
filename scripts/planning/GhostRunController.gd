extends Node

# --- Configuration ---
const MAX_DURATION: float = 600.0 # 10 minutes max
const RECORDING_TICK: float = 0.1 # Record every 0.1s

# --- State ---
var current_time: float = 0.0
var is_recording: bool = false
var is_playing: bool = false
var active_character: CharacterData = null # The character currently being recorded

# --- Data ---
# { character_name: [ {time: 0.0, pos: Vector2(), action: "move"}, ... ] }
var recorded_tracks: Dictionary = {} 
var current_recording_buffer: Array[Dictionary] = []

# { character_name: [ {start: float, end: float}, ... ] }
var detection_intervals: Dictionary = {}

# Planning Data Reference for smarter playback
var current_plan: PlanningData

# Cache for calculated delays per character
# { char_name: [ {at_time: 10.0, duration: 5.0} ] }
var playback_delays: Dictionary = {}

# { signal_name: time_emitted }
var emitted_signals: Dictionary = {}

# Tracking playback progress for actions
# { char_name: next_action_index (int) }
var playback_action_cursors: Dictionary = {}

# --- Signals ---
signal time_changed(new_time: float)
signal recording_started(character: CharacterData)
signal recording_finished(character: CharacterData)
signal playback_finished
signal action_triggered(character_name: String, action_type: String, action_data: Dictionary)

func _physics_process(delta: float) -> void:
	if GameManager.current_state != GameManager.State.PLANNING and GameManager.current_state != GameManager.State.ACTION:
		return

	if is_recording:
		_process_recording(delta)
	elif is_playing:
		_process_playback(delta)

# --- Recording Logic ---

func start_recording(character: CharacterData) -> void:
	if not character:
		push_error("Cannot start recording: No character provided.")
		return
		
	active_character = character
	current_time = 0.0
	current_recording_buffer.clear()
	is_recording = true
	is_playing = true # We play others while recording self
	
	recording_started.emit(character)
	print("Started recording for: ", character.name)

func stop_recording(save: bool = true) -> void:
	if not is_recording:
		return
		
	is_recording = false
	is_playing = false
	
	if save and active_character:
		recorded_tracks[active_character.name] = current_recording_buffer.duplicate()
		print("Saved track for ", active_character.name, ". Points: ", current_recording_buffer.size())
		recording_finished.emit(active_character)
	else:
		print("Recording aborted.")
		
	active_character = null

func _process_recording(delta: float) -> void:
	current_time += delta
	if current_time >= MAX_DURATION:
		stop_recording(true)
		return
	time_changed.emit(current_time)

func record_frame(position: Vector2, velocity: Vector2, action_state: Dictionary) -> void:
	if not is_recording: 
		return
	var frame = {
		"time": current_time,
		"pos": position,
		"vel": velocity,
		"actions": action_state
	}
	current_recording_buffer.append(frame)

# --- Playback Logic ---

func set_plan(plan: PlanningData):
	current_plan = plan
	_recalculate_delays()

func _recalculate_delays():
	playback_delays.clear()
	emitted_signals.clear()
	if not current_plan: return
	
	# Initial pass: identify all characters and their basic action durations
	for char_name in current_plan.character_plans:
		playback_delays[char_name] = []
	
	# We need to resolve signals. This can be complex if signals depend on other signals.
	# We use an iterative approach (max 10 passes should be enough for typical plans)
	for pass_idx in range(10):
		var changed = false
		
		for char_name in current_plan.character_plans:
			var char_plan = current_plan.character_plans[char_name]
			var current_delays = playback_delays[char_name]
			current_delays.clear()
			
			var accumulated_delay = 0.0
			
			for action in char_plan.actions:
				# 1. Handle WAIT (explicit duration)
				if action.type == "WAIT":
					current_delays.append({"at_time": action.time, "duration": action.duration})
					accumulated_delay += action.duration
				
				# 2. Handle Synchronization (WAIT FOR SIGNAL)
				if action.wait_for_signal != "":
					var sig_name = action.wait_for_signal
					var emit_time = emitted_signals.get(sig_name, -1.0)
					
					# Effective time when this character reaches the action
					var reach_time = action.time + accumulated_delay
					
					if emit_time > reach_time:
						# Character must wait until signal is emitted
						var wait_duration = emit_time - reach_time
						current_delays.append({"at_time": action.time, "duration": wait_duration})
						accumulated_delay += wait_duration
					elif emit_time < 0:
						# Signal not emitted yet (or ever). For planning, assume infinite wait
						# or a very long duration to indicate blockage.
						# During simulation, we can't move past here.
						current_delays.append({"at_time": action.time, "duration": 3600.0}) # 1 hour wait
						accumulated_delay += 3600.0
				
				# 3. Handle Signal Emission
				if action.emit_signal_on_complete != "":
					var sig_name = action.emit_signal_on_complete
					# Signal is emitted AFTER action duration
					var finish_time = action.time + accumulated_delay + action.duration
					
					if not emitted_signals.has(sig_name) or emitted_signals[sig_name] != finish_time:
						emitted_signals[sig_name] = finish_time
						changed = true
			
		if not changed:
			break
	
	print("GhostRun: Recalculated delays and signals. Signals: ", emitted_signals.keys())

func get_effective_time(char_name: String, global_time: float) -> float:
	if not playback_delays.has(char_name):
		return global_time
		
	var delays = playback_delays[char_name]
	var current_global = 0.0
	var current_effective = 0.0
	
	# We need to traverse global time and subtract delays that happened before it
	# A delay happens at 'effective_time'.
	for delay in delays:
		var global_start_of_delay = delay.at_time + (current_global - current_effective)
		
		if global_time < global_start_of_delay:
			# We are before this delay
			break
		elif global_time < global_start_of_delay + delay.duration:
			# We are inside the delay (waiting)
			return delay.at_time
		else:
			# We have passed this delay
			current_global += delay.duration
			
	return max(0.0, global_time - (current_global - 0.0))

func play_simulation() -> void:
	current_time = 0.0
	is_playing = true
	is_recording = false
	# Reset action cursors
	playback_action_cursors.clear()
	if current_plan:
		for char_name in current_plan.character_plans:
			playback_action_cursors[char_name] = 0

func stop_simulation() -> void:
	is_playing = false

func _process_playback(delta: float) -> void:
	var prev_time = current_time
	current_time += delta
	
	if current_time >= MAX_DURATION:
		stop_simulation()
		playback_finished.emit()
		return
	
	time_changed.emit(current_time)
	
	# Check for actions triggered in this frame
	if current_plan:
		for char_name in current_plan.character_plans:
			var char_plan = current_plan.character_plans[char_name]
			var cursor = playback_action_cursors.get(char_name, 0)
			
			while cursor < char_plan.actions.size():
				var action = char_plan.actions[cursor]
				
				# Simple check for trigger
				if action.time <= current_time and action.time > prev_time:
					# Trigger!
					var data = {
						"target_id": action.target_id,
						"tool_id": action.selected_tool_id,
						"duration": action.duration
					}
					action_triggered.emit(char_name, action.type, data)
					cursor += 1
				elif action.time > current_time:
					break # Future action
				else:
					# Action in past
					cursor += 1
			
			playback_action_cursors[char_name] = cursor

# --- Query API for Ghost Agents ---

func get_state_at_time(character_name: String, time: float) -> Dictionary:
	if not recorded_tracks.has(character_name):
		return {}
		
	var track: Array = recorded_tracks[character_name]
	if track.is_empty():
		return {}
	
	# Apply Time Shift based on Plan
	var effective_time = get_effective_time(character_name, time)
		
	# Binary search or simple iteration
	for i in range(track.size() - 1):
		if track[i].time <= effective_time and track[i+1].time > effective_time:
			# Interpolate between frames i and i+1
			var t_start = track[i].time
			var t_end = track[i+1].time
			var weight = (effective_time - t_start) / (t_end - t_start)
			
			var frame_a = track[i]
			var frame_b = track[i+1]
			
			return {
				"pos": lerp(frame_a.pos, frame_b.pos, weight),
				"vel": lerp(frame_a.vel, frame_b.vel, weight),
				"actions": frame_a.actions 
			}
			
	return track.back() # Return last known state if time > duration

# --- Analysis API for Timeline UI ---

func analyze_track(character_name: String) -> Array:

	if not recorded_tracks.has(character_name):

		return []

		

	var track = recorded_tracks[character_name]

	if track.is_empty():

		return []

		

	var blocks = []

	var current_block = null

	

	for i in range(track.size()):

		var frame = track[i]

		var type = "idle"

		

		# Determine type

		if frame.actions.get("interact", false):

			type = "interact"

		elif frame.vel.length_squared() > 10.0: # Moving threshold

			type = "move"

			

		if current_block == null:

			current_block = {"start": frame.time, "end": frame.time, "type": type}

		elif current_block.type != type:

			# Close block

			current_block.end = frame.time

			blocks.append(current_block)

			# Start new

			current_block = {"start": frame.time, "end": frame.time, "type": type}

		else:

			# Extend

			current_block.end = frame.time

			

	if current_block:

		blocks.append(current_block)

		

	return blocks



func record_detection(character_name: String, time: float):

	if not detection_intervals.has(character_name):

		detection_intervals[character_name] = []

		

	var intervals = detection_intervals[character_name]

	

	if intervals.is_empty() or intervals.back().end < time - 0.2:

		# New interval

		intervals.append({"start": time, "end": time})

	else:

		# Extend existing

		intervals.back().end = time



func clear_detection_data(character_name: String = ""):

	if character_name == "":

		detection_intervals.clear()

	else:

		detection_intervals[character_name] = []
