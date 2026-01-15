extends Control

signal dialogue_finished(choice_index)

@onready var name_tag = $DialogPanel/Margin/Content/TextColumn/NameTag
@onready var dialogue_text = $DialogPanel/Margin/Content/TextColumn/DialogueText
@onready var portrait = $DialogPanel/Margin/Content/PortraitFrame/Portrait
@onready var choices_container = $DialogPanel/Margin/Content/ChoicesColumn

var _full_text: String = ""
var _is_typing: bool = false
var _type_speed: float = 0.03
var _current_pitch: float = 1.0

func _ready():
	hide()
	EventBus.request_start_dialogue.connect(show_dialogue)

func show_dialogue(character_name: String, text: String, portrait_path: String = "", choices: Array = [], character_data: CharacterData = null):
	show()
	name_tag.text = character_name.to_upper()
	_full_text = text
	dialogue_text.text = ""
	_current_pitch = 1.0
	
	if character_data:
		_current_pitch = character_data.voice_pitch
		if character_data.greeting_audio:
			AudioManager.play_ui(character_data.greeting_audio, -5.0, _current_pitch)
		
		if character_data.portrait:
			portrait.texture = character_data.portrait
			portrait.get_parent().show()
			_clear_choices()
			_start_typewriter()
			_setup_choices(choices)
			return

	if portrait_path != "" and ResourceLoader.exists(portrait_path):
		portrait.texture = load(portrait_path)
		portrait.get_parent().show()
	else:
		portrait.get_parent().hide()

	_clear_choices()
	_start_typewriter()
	
	# Delay choices until text is mostly done or show them immediately?
	# For now, show immediately to allow skipping or fast flow
	_setup_choices(choices)

func _start_typewriter():
	_is_typing = true
	dialogue_text.visible_ratio = 0.0
	var tween = create_tween()
	var duration = _full_text.length() * _type_speed
	dialogue_text.text = _full_text
	
	# Connect to the step of the tween to play sound
	var counter = [0] # Use array for reference capture
	tween.tween_method(func(ratio): 
		dialogue_text.visible_ratio = ratio
		var current_char_count = int(ratio * _full_text.length())
		if current_char_count > counter[0] and current_char_count % 3 == 0:
			AudioManager.play_dialogue_blip(_current_pitch)
			counter[0] = current_char_count
	, 0.0, 1.0, duration)
	
	tween.finished.connect(func(): _is_typing = false)

func _clear_choices():
	for child in choices_container.get_children():
		child.queue_free()

func _setup_choices(choices: Array):
	if choices.is_empty():
		var btn = Button.new()
		btn.text = "> POKRAČOVAT"
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.pressed.connect(_on_choice_selected.bind(-1))
		choices_container.add_child(btn)
	else:
		for i in range(choices.size()):
			var btn = Button.new()
			btn.text = "> " + choices[i].to_upper()
			btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
			btn.pressed.connect(_on_choice_selected.bind(i))
			choices_container.add_child(btn)

func _on_choice_selected(index: int):
	if _is_typing:
		# Skip typewriter if still typing
		dialogue_text.visible_ratio = 1.0
		_is_typing = false
		return

	hide()
	dialogue_finished.emit(index)

func _input(event):
	if visible and event.is_action_pressed("ui_accept"):
		if _is_typing:
			dialogue_text.visible_ratio = 1.0
			_is_typing = false
		elif choices_container.get_child_count() == 1:
			# If only "Continue" is present
			_on_choice_selected(-1)