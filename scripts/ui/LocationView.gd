extends Control

@onready var title_label = $Panel/Title
@onready var char_container = $Panel/Scroll/CharContainer
@onready var btn_close = $Panel/Btn_Close

var current_location_id: String

func _ready():
	btn_close.pressed.connect(queue_free)
	TimeManager.time_changed.connect(func(_slot): _refresh_characters())

func setup(location_id: String, location_name: String):
	current_location_id = location_id
	title_label.text = location_name
	
	# Load Location Background
	var bg_path = "res://assets/locations/" + location_id.to_snake_case() + "_bg.png"
	if ResourceLoader.exists(bg_path):
		var bg_texture = load(bg_path)
		# Try to find a TextureRect named Background or similar
		var bg_node = get_node_or_null("Background")
		if bg_node and bg_node is TextureRect:
			bg_node.texture = bg_texture
	
	# Handle Map Events
	var event = MapEventManager.get_event_for(location_id)
	if not event.is_empty():
		_apply_event_effect(event)
		
	_refresh_characters()

func _apply_event_effect(event: Dictionary):
	# Add a warning label to the top of character list or title
	var warning = Label.new()
	warning.text = "!!! %s !!!\n%s" % [event.label, event.description]
	warning.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	warning.add_theme_color_override("font_color", Color.YELLOW)
	
	if event.type == MapEventManager.EventType.POLICE_RAID:
		warning.add_theme_color_override("font_color", Color.RED)
		# Penalty for entering
		GameManager.add_heat(event.heat_penalty)
		print("Consequence: Raid entry penalty applied (+", event.heat_penalty, " Heat)")
		
	char_container.add_child(warning)
	char_container.move_child(warning, 0)

func _refresh_characters():
	for child in char_container.get_children():
		child.queue_free()
		
	var time_key = TimeManager.get_schedule_key()
	
	for character in AdventureManager.available_characters:
		# Check if character is at this location at this time
		var char_location = character.schedule.get(time_key, "")
		
		if char_location == current_location_id:
			# Special case for Honza
			if character.name == "Honza" and not StoryManager.story_flags["tutorial_call_received"]:
				continue
				
			_add_character_row(character)

func _add_character_row(character: CharacterData):
	var panel = PanelContainer.new()
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 20)
	panel.add_child(hbox)
	
	# Portrait
	if character.portrait:
		var rect = TextureRect.new()
		rect.texture = character.portrait
		rect.custom_minimum_size = Vector2(80, 80)
		rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		hbox.add_child(rect)
	
	# Info VBox
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = SIZE_EXPAND_FILL
	hbox.add_child(vbox)
	
	var name_lbl = Label.new()
	name_lbl.text = character.name + " (" + character.role + ")"
	name_lbl.add_theme_font_size_override("font_size", 20)
	vbox.add_child(name_lbl)
	
	var desc_lbl = Label.new()
	desc_lbl.text = character.description
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(desc_lbl)
	
	# Stats
	var stats_lbl = Label.new()
	stats_lbl.text = "S: %d | L: %d | E: %d | D: %d" % [character.stealth, character.lock_picking, character.electronics, character.driving]
	stats_lbl.modulate = Color(0.7, 0.7, 1.0)
	vbox.add_child(stats_lbl)
	
	# Buttons Column
	var btn_vbox = VBoxContainer.new()
	btn_vbox.custom_minimum_size.x = 180
	hbox.add_child(btn_vbox)
	
	# Talk Button
	var btn_talk = Button.new()
	btn_talk.text = "MLUVIT"
	btn_talk.pressed.connect(_on_talk_pressed.bind(character))
	btn_vbox.add_child(btn_talk)
	
	# Hire Button
	if character.is_hirable:
		var btn_hire = Button.new()
		if AdventureManager.is_hired(character.name):
			btn_hire.text = "V TÝMU"
			btn_hire.disabled = true
		else:
			btn_hire.text = "NAJMOUT (%d CZK)" % character.hiring_cost
			btn_hire.pressed.connect(_on_hire_pressed.bind(character))
		btn_vbox.add_child(btn_hire)
	
	char_container.add_child(panel)

func _on_talk_pressed(character: CharacterData):
	var text = character.greeting_text
	
	# Special Narrative Overrides (from Narrative_Melnik_2025.md)
	if character.name == "Honza":
		text = NarrativeManager.get_honza_greet()
	elif character.name == "Petra" and NarrativeManager.loop_count > 1:
		text = tr("npc_petra_loop_01")
	elif character.name == "Josef" and NarrativeManager.loop_count > 2:
		text = tr("npc_josef_loop_01")
		
	if text == "":
		text = "Nemám ti teď co říct, šéfe."
	
	# Replace name placeholder
	text = text.replace("[NAME]", GameManager.player_name if GameManager.player_name != "" else "parťáku")
	
	EventBus.request_start_dialogue.emit(character.name, text, "", [], character)

func _on_hire_pressed(character: CharacterData):
	if AdventureManager.hire_character(character):
		_refresh_characters()
