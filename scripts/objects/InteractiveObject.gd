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
	var _time_modifier = 1.0

	if used_tool_id != "":
		# Explicit tool from plan
		if tool_options.has(used_tool_id):
			if char_data.has_item(used_tool_id):
				var opts = tool_options[used_tool_id]
				noise_radius = opts.get("noise", 50.0)
				_time_modifier = opts.get("time_mod", 1.0)
			else:
				interaction_failed.emit(agent, "missing_tool_" + used_tool_id)
				return false
		elif required_tool == used_tool_id:
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
	print(agent.name, " interacted with ", object_name, " using ", used_tool_id if used_tool_id else "hands")
	
	# Emit Noise
	if noise_radius > 0:
		NoiseSystem.emit_noise(global_position, noise_radius)
	
	interacted.emit(agent)
	_on_interact(agent)
	return true

func _on_interact(_agent: Node) -> void:
	pass
