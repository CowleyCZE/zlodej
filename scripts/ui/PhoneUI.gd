class_name PhoneUI
extends Control

signal call_accepted
signal call_rejected

# Změna z @onready na var, abychom předešli chybám při dynamickém vytváření
var panel: Panel
var caller_label: Label
var portrait: TextureRect
var ring_timer: Timer

var current_event: StoryEvent

func _ready():
	visible = false
	
	# Pokud uzly existují ve scéně (např. z editoru), přiřadíme je
	if has_node("Panel"):
		panel = $Panel
		if panel.has_node("CallerLabel"): caller_label = $Panel/CallerLabel
		if panel.has_node("Portrait"): portrait = $Panel/Portrait
	
	if has_node("RingTimer"):
		ring_timer = $RingTimer
	
	# Pokud klíčové prvky chybí, vytvoříme je dynamicky
	if not panel:
		_create_ui()

func _create_ui():
	# Prototyp UI v kódu
	var p = Panel.new()
	p.name = "Panel"
	p.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	p.position.y = -150 # Vysunutí
	p.size = Vector2(300, 100)
	add_child(p)
	panel = p
	
	var l = Label.new()
	l.name = "CallerLabel"
	l.text = "Příchozí hovor..."
	l.position = Vector2(10, 10)
	p.add_child(l)
	caller_label = l
	
	var btn_accept = Button.new()
	btn_accept.text = "PŘIJMOUT (Enter)"
	btn_accept.position = Vector2(10, 50)
	btn_accept.pressed.connect(_on_accept_pressed)
	p.add_child(btn_accept)
	
	var btn_reject = Button.new()
	btn_reject.text = "ODMÍTNOUT (Esc)"
	btn_reject.position = Vector2(160, 50)
	btn_reject.pressed.connect(_on_reject_pressed)
	p.add_child(btn_reject)
	
	# Timer pro blikání nebo vibrace
	var t = Timer.new()
	t.name = "RingTimer"
	t.wait_time = 1.0
	t.one_shot = false
	add_child(t)
	ring_timer = t

func show_call(event: StoryEvent):
	current_event = event
	if caller_label:
		caller_label.text = "Volá: " + event.character_name
	visible = true
	# Animace vysunutí (Tween) by byla zde
	AudioManager.play_phone_ring()

func _on_accept_pressed():
	visible = false
	AudioManager.stop_phone_ring()
	call_accepted.emit()
	# Spustíme dialog přes EventBus
	EventBus.request_start_dialogue.emit(current_event.character_name, current_event.dialogue_text, "", [], null)

func _on_reject_pressed():
	visible = false
	AudioManager.stop_phone_ring()
	call_rejected.emit()

func _input(event):
	if not visible: return
	if event.is_action_pressed("ui_accept"):
		_on_accept_pressed()
	elif event.is_action_pressed("ui_cancel"):
		_on_reject_pressed()