extends PanelContainer

var character_data: CharacterData

func setup(data: CharacterData) -> void:
	character_data = data
	_update_ui()

func _update_ui() -> void:
	if not character_data:
		return
		
	# Basic Info
	$HBox/MainInfo/NameLabel.text = character_data.name
	$HBox/MainInfo/RoleLabel.text = "Role: " + character_data.current_role.to_upper()
	$HBox/ActionPanel/CostLabel.text = "%s CZK" % character_data.hiring_cost
	
	# Stats (Simplified view)
	var stats_text_1 = ""
	var stats_text_2 = ""
	
	# Primary Stats based on role
	if character_data.driving > 50: stats_text_1 += "DRIVE: %d " % character_data.driving
	if character_data.electronics > 50: stats_text_1 += "HACK: %d " % character_data.electronics
	if character_data.lock_picking > 50: stats_text_1 += "LOCK: %d " % character_data.lock_picking
	if character_data.strength > 50: stats_text_1 += "STR: %d " % character_data.strength
	
	stats_text_2 += "LOYALTY: %d" % character_data.loyalty
	
	$HBox/MainInfo/StatsBox/Stat1.text = stats_text_1
	$HBox/MainInfo/StatsBox/Stat2.text = stats_text_2
	
	# Button State
	_update_button_state()

func _update_button_state() -> void:
	var btn = $HBox/ActionPanel/HireButton
	
	if AdventureManager.is_hired(character_data.name):
		btn.text = "NAJATO"
		btn.disabled = true
		modulate = Color(0.7, 1.0, 0.7, 1.0) # Greenish tint
	elif EconomyManager.wallet < character_data.hiring_cost:
		btn.text = "NEDOSTATEK"
		btn.disabled = true
		modulate = Color(1.0, 1.0, 1.0, 0.5) # Dimmed
	else:
		btn.text = "NAJMOUT"
		btn.disabled = false
		modulate = Color(1, 1, 1, 1)

func _on_hire_button_pressed() -> void:
	if AdventureManager.hire_character(character_data):
		_update_button_state()
		# Optional: Play sound via AudioManager logic here
