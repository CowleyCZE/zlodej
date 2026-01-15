extends Control

@onready var global_list = $Panel/HBox/GlobalInv/ItemList
@onready var char_list = $Panel/HBox/CharInv/ItemList
@onready var char_label = $Panel/HBox/CharInv/Label

var current_char: CharacterData

func setup(character: CharacterData):
	current_char = character
	char_label.text = character.name
	refresh()

func refresh():
	global_list.clear()
	char_list.clear()
	
	# Global Inventory
	for entry in InventoryManager.items:
		var item = entry.item
		global_list.add_item(item.name + " (" + str(entry.quantity) + ")", item.icon)
		global_list.set_item_metadata(global_list.get_item_count() - 1, item)

	# Character Inventory
	for item_id in current_char.inventory:
		# Try to find resource to get name/icon
		var item_res = _find_item_resource(item_id)
		if item_res:
			char_list.add_item(item_res.name, item_res.icon)
		else:
			char_list.add_item(item_id) # Fallback ID
		char_list.set_item_metadata(char_list.get_item_count() - 1, item_id)

func _find_item_resource(id: String) -> InventoryItem:
	# 1. Search global inventory first (fastest)
	for entry in InventoryManager.items:
		if entry.item.id == id:
			return entry.item
	
	# 2. Try loading from standard path (Convention)
	# Assuming items are stored in res://resources/items/
	# This requires the user to maintain this structure
	# For MVP, we might just return null if not in global
	return null

func _on_global_item_activated(index):
	var item = global_list.get_item_metadata(index) as InventoryItem
	if InventoryManager.remove_item(item.id, 1):
		current_char.add_item(item.id)
		refresh()

func _on_char_item_activated(index):
	var item_id = char_list.get_item_metadata(index) as String
	
	# We need the resource to add back
	var item_res = _find_item_resource(item_id)
	
	# If we can't find the resource, we can't add it back safely to InventoryManager 
	# because it expects a Resource.
	# HACK: If we can't find it, we assume it's lost or create a dummy?
	# Better: Don't allow moving if resource missing.
	
	if item_res:
		if current_char.remove_item(item_id):
			InventoryManager.add_item(item_res, 1)
			refresh()
	else:
		print("Error: Cannot return item, resource definition not found.")

func _on_close_pressed():
	hide()
