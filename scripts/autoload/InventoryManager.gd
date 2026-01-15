# InventoryManager.gd (Autoload)
extends Node

var items: Array[Dictionary] = [] # Array of { "item": InventoryItem, "quantity": int }
var max_weight: float = 20.0
var current_weight: float = 0.0

signal inventory_updated

func clear_inventory():
	items.clear()
	current_weight = 0.0
	inventory_updated.emit()
	EventBus.inventory_changed.emit()

func add_item(item_resource: InventoryItem, quantity: int = 1) -> bool:
	# Check weight
	if current_weight + (item_resource.weight * quantity) > max_weight:
		print("Inventář je příliš těžký!")
		return false
	
	# Check if stackable and already exists
	if item_resource.is_stackable:
		for entry in items:
			if entry.item.id == item_resource.id:
				entry.quantity += quantity
				_recalculate_weight()
				inventory_updated.emit()
				EventBus.inventory_changed.emit()
				return true
	
	# Add as new entry
	items.append({ "item": item_resource, "quantity": quantity })
	_recalculate_weight()
	inventory_updated.emit()
	EventBus.inventory_changed.emit()
	SaveManager.save_game()
	return true

func load_item_direct(item_resource: InventoryItem, quantity: int = 1):
	# Direct addition for SaveManager (bypasses weight check for loading)
	items.append({ "item": item_resource, "quantity": quantity })
	# Note: Weight should be recalculated after all items are loaded

func finalize_load():
	_recalculate_weight()
	inventory_updated.emit()
	EventBus.inventory_changed.emit()

func remove_item(item_id: String, quantity: int = 1) -> bool:
	for i in range(items.size()):
		if items[i].item.id == item_id:
			if items[i].quantity > quantity:
				items[i].quantity -= quantity
			else:
				items.remove_at(i)
			_recalculate_weight()
			inventory_updated.emit()
			EventBus.inventory_changed.emit()
			SaveManager.save_game()
			return true
	return false

func has_item(item_id: String) -> bool:
	for entry in items:
		if entry.item.id == item_id:
			return true
	return false

func _recalculate_weight():
	current_weight = 0.0
	for entry in items:
		current_weight += entry.item.weight * entry.quantity
