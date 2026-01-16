class_name LoadoutUI
extends Control

@onready var team_container = $Main/TeamScroll/TeamContainer
@onready var stash_container = $Main/InventoryScroll/StashContainer
@onready var btn_close = $Main/Btn_Done

var planning_manager

func setup(manager):
	planning_manager = manager
	_refresh_stash()
	_refresh_team()

func _ready():
	if btn_close:
		btn_close.pressed.connect(_on_close_pressed)

func _refresh_stash():
	for child in stash_container.get_children():
		child.queue_free()
		
	for entry in InventoryManager.items:
		var btn = Button.new()
		btn.text = "%s (x%d)" % [entry.item.name, entry.quantity]
		btn.custom_minimum_size = Vector2(150, 40)
		btn.pressed.connect(_on_item_to_team.bind(entry.item))
		stash_container.add_child(btn)

func _refresh_team():
	for child in team_container.get_children():
		child.queue_free()
		
	if not planning_manager: return
	
	for character in planning_manager.team:
		var panel = PanelContainer.new()
		var vbox = VBoxContainer.new()
		panel.add_child(vbox)
		
		var name_lbl = Label.new()
		name_lbl.text = character.name
		vbox.add_child(name_lbl)
		
		# Show current inventory of this character
		var item_hbox = HBoxContainer.new()
		vbox.add_child(item_hbox)
		
		for item_id in character.inventory:
			var item_lbl = Label.new()
			item_lbl.text = "[" + item_id + "]"
			item_lbl.modulate = Color.CYAN
			item_hbox.add_child(item_lbl)
			
			var rem_btn = Button.new()
			rem_btn.text = "x"
			rem_btn.pressed.connect(_on_remove_item.bind(character, item_id))
			item_hbox.add_child(rem_btn)
			
		team_container.add_child(panel)

func _on_item_to_team(item: InventoryItem):
	# Add to currently selected character in planning
	var char_idx = planning_manager.selected_character_index
	if char_idx >= 0 and char_idx < planning_manager.team.size():
		var character = planning_manager.team[char_idx]
		character.add_item(item.id)
		# For simulation, we remove from global inventory? Or keep?
		# GDD implies managing equipment, usually it means assigning.
		_refresh_team()

func _on_remove_item(character: CharacterData, item_id: String):
	character.remove_item(item_id)
	_refresh_team()

func _on_close_pressed():
	visible = false
