class_name InteractiveObject
extends Node2D

signal interacted(agent)
signal interaction_failed(agent, reason)

@export var object_name: String = "Object"
@export var interaction_time: float = 0.5

# Legacy/Simple
@export var required_tool: String = "" 

# Advanced Tool Logic (Tool ID -> {time_mod: float, noise: float})
@export var tool_options: Dictionary = {} 

func get_interaction_position() -> Vector2:
	return global_position

func interact(agent: Node, used_tool_id: String = "") -> bool:
	var char_data = agent.get("character_data") as CharacterData
	if not char_data:
		return false

	# 1. Determine effective tool stats
	var noise_radius = 10.0
	var time_modifier = 1.0

	# Apply skills (Point 2: unique abilities)
	if required_tool == "lockpick" or used_tool_id == "lockpick_set":
		time_modifier = 1.0 - (char_data.lock_picking / 200.0) # 100 skill = 50% time
	elif required_tool == "hacking":
		time_modifier = 1.0 - (char_data.electronics / 200.0)

	if used_tool_id != "":
		# Explicit tool from plan
		if tool_options.has(used_tool_id):
			if char_data.has_item(used_tool_id):
				var opts = tool_options[used_tool_id]
				noise_radius = opts.get("noise", 50.0)
				time_modifier *= opts.get("time_mod", 1.0)
			else:
				interaction_failed.emit(agent, "missing_tool_" + used_tool_id)
				return false
		elif required_tool == used_tool_id or (required_tool == "lockpick" and used_tool_id == "lockpick_set"):
			# Matches legacy requirement
			if not char_data.has_item(used_tool_id):
				interaction_failed.emit(agent, "missing_tool_" + used_tool_id)
				return false
		else:
			# Tool not applicable
			interaction_failed.emit(agent, "wrong_tool_" + used_tool_id)
			return false
	else:
		# Auto-select or Fallback (Manual Mode)
		if required_tool != "" and not char_data.has_item(required_tool):
			interaction_failed.emit(agent, "missing_tool_" + required_tool)
			return false

	# 2. Execute
	var effective_time = interaction_time * time_modifier
	print(agent.name, " interacting with ", object_name, " (Time: ", effective_time, "s)")
	
	_play_skeuomorphic_feedback()
	
	# Emit Noise
	if noise_radius > 0:
		NoiseSystem.emit_noise(global_position, noise_radius)
	
	# Delay completion by effective time
	if effective_time > 0:
		await get_tree().create_timer(effective_time).timeout

	interacted.emit(agent)
	_on_interact(agent)
	return true

func _play_skeuomorphic_feedback():
	# UI Design Guidelines 3.2: Semi-Skeuomorphic Accent
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_OUT)
	
	# Scale pulse
	tween.tween_property(self, "scale", Vector2(1.15, 1.15), 0.2)
	tween.chain().tween_property(self, "scale", Vector2(1.0, 1.0), 0.2)
	
	# Visual color flash (Golden for interaction success)
	# Assuming there is a visual node to modulate
	var visual = get_node_or_null("Visual")
	if not visual: visual = get_node_or_null("Sprite2D")
	
	if visual:
		var initial_mod = visual.modulate
		tween.tween_property(visual, "modulate", Color(1.0, 0.7, 0.0, 1.0), 0.1) # Gold Ember #FFB400
		tween.chain().tween_property(visual, "modulate", initial_mod, 0.3)

func _on_interact(_agent: Node) -> void:
	pass
