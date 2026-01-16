# GadgetEffectSystem.gd
extends Node

# Tento systém aplikuje efekty gadgetů (EMP, Jammer, atd.) na herní svět
# v Action Mode.

const GROUP_ELECTRONICS = "electronics"
const GROUP_GUARDS = "guards"

# Vrací true, pokud gadget má nějaký efekt
static func apply_gadget_effect(gadget_id: String, origin_node: Node2D, world_root: Node2D) -> bool:
	if not EconomyManager.item_db.has(gadget_id):
		return false
		
	var item = EconomyManager.item_db[gadget_id]
	if item.effect_type == "none":
		return false

	print("Applying gadget effect: ", item.name, " [", item.effect_type, "]")
	
	match item.effect_type:
		"disable_electronics":
			_apply_disable_electronics(origin_node.global_position, item.effect_radius, item.effect_duration, world_root)
		"block_signal":
			_apply_block_signal(origin_node.global_position, item.effect_radius, item.effect_duration, world_root)
		"stun_npc":
			_apply_stun_npc(origin_node, item.effect_duration, gadget_id)
			
	return true

static func _apply_disable_electronics(center: Vector2, radius: float, duration: float, root: Node):
	if not root.is_inside_tree():
		return

	var targets = root.get_tree().get_nodes_in_group(GROUP_ELECTRONICS)
	var count = 0
	
	for target in targets:
		if target is Node2D:
			var dist = center.distance_to(target.global_position)
			var pixel_radius = radius * 32.0 
			
			if radius > 0 and dist <= pixel_radius:
				if target.has_method("disable_temporarily"):
					target.disable_temporarily(duration)
					count += 1
						
	print("EMP hit ", count, " targets.")

static func _apply_block_signal(_center: Vector2, _radius: float, _duration: float, _root: Node):
	# TODO: Implementovat pro Guards (znemožnit volání vysílačkou)
	pass

static func _apply_stun_npc(origin_node: Node2D, duration: float, tool_id: String):
	# Taser/Knife logic - target nearest guard in range
	var guards = origin_node.get_tree().get_nodes_in_group(GROUP_GUARDS)
	var nearest_guard = null
	var min_dist = 100.0 # Standard melee range
	
	for guard in guards:
		if guard is Guard:
			var dist = origin_node.global_position.distance_to(guard.global_position)
			if dist < min_dist:
				min_dist = dist
				nearest_guard = guard
				
	if nearest_guard:
		var is_lethal = false
		if EconomyManager.item_db.has(tool_id):
			is_lethal = EconomyManager.item_db[tool_id].is_lethal
		
		nearest_guard.apply_hit(is_lethal, duration)
		print("GadgetSystem: Hit applied to ", nearest_guard.name, " via ", tool_id, " Lethal: ", is_lethal)
