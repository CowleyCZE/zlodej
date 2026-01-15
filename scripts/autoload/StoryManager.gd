# scripts/autoload/StoryManager.gd
extends Node

# Příběhové flagy (persistentní)
var story_flags: Dictionary = {
	"tutorial_call_received": false,
	"met_honza_in_pub": false,
	"first_mission_unlocked": false
}

# Fronta aktivních událostí
var event_queue: Array[StoryEvent] = []
var active_events: Array[StoryEvent] = [] # Všechny definované eventy ve hře

# Reference na UI (bude nastaveno z Game.gd nebo MainScene)
var phone_ui: PhoneUI

func _ready():
	EventBus.game_state_changed.connect(_on_game_state_changed)
	_load_events()

func _load_events():
	# Zde bychom normálně načetli .tres soubory ze složky resources/events/
	# Prozatím vytvoříme eventy programově
	
	var evt1 = StoryEvent.new()
	evt1.event_id = "call_tutorial"
	evt1.character_name = "Honza"
	evt1.title = "Nabídka práce"
	evt1.dialogue_text = "Hej [NAME], slyšel jsem, že jseš v Mělníku. Mám pro tebe první robotu - taková ta jednoduchá. Když se osvědčíš, máme spousty peněz. Jezdi za mnou do hospody U Černého Orla."
	evt1.trigger_delay_seconds = 2.0
	evt1.set_story_flag = "tutorial_call_received"
	active_events.append(evt1)

func _on_game_state_changed(new_state):
	if new_state == GameManager.State.ADVENTURE:
		# Odložíme kontrolu, aby se scéna stihla načíst
		get_tree().create_timer(1.0).timeout.connect(_check_story_triggers)

func _check_story_triggers():
	print("StoryManager: Checking triggers...")
	for event in active_events:
		if _can_trigger(event):
			_trigger_event(event)

func _can_trigger(event: StoryEvent) -> bool:
	# 1. Zkontroluj, zda už nebyl splněn (pokud je jednorázový)
	if event.set_story_flag != "" and story_flags.get(event.set_story_flag, false):
		return false
		
	# 2. Kontrola reputace
	if GameManager.reputation < event.required_reputation:
		return false
		
	# 3. Kontrola mise (pokud je vyžadována)
	if event.required_mission_completed != "":
		# Zde by byla logika kontroly completion z MissionDB
		# if not MissionDB.is_completed(event.required_mission_completed): return false
		pass
		
	return true

func _trigger_event(event: StoryEvent):
	print("StoryManager: Triggering event ", event.event_id)
	
	if event.is_phone_call:
		# Zobrazit telefon
		if phone_ui:
			phone_ui.show_call(event)
		else:
			# Fallback pokud není UI telefonu - rovnou dialog
			_start_dialogue_from_event(event)
	else:
		# Jiný typ eventu (např. rovnou dialog nebo cutscéna)
		_start_dialogue_from_event(event)

func _start_dialogue_from_event(event: StoryEvent):
	var text = event.dialogue_text.replace("[NAME]", GameManager.player_name if GameManager.player_name != "" else "parťáku")
	EventBus.request_start_dialogue.emit(event.character_name, text, "", [], null)
	
	# Aplikovat efekty
	if event.set_story_flag != "":
		story_flags[event.set_story_flag] = true
	if event.add_money > 0:
		GameManager.add_money(event.add_money)
	if event.unlock_mission_id != "":
		ProgressManager.unlock_mission(event.unlock_mission_id)
		
	SaveManager.save_game()

func register_phone_ui(ui: PhoneUI):
	phone_ui = ui
	# Propojení signálů z UI
	if not phone_ui.call_accepted.is_connected(_on_call_accepted):
		phone_ui.call_accepted.connect(_on_call_accepted)

func _on_call_accepted():
	if phone_ui.current_event:
		_start_dialogue_from_event(phone_ui.current_event)

# --- Persistence ---
func serialize() -> Dictionary:
	return story_flags

func deserialize(data: Dictionary):
	for key in data:
		if story_flags.has(key):
			story_flags[key] = data[key]
