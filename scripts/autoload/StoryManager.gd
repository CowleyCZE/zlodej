# scripts/autoload/StoryManager.gd
extends Node

# Příběhové flagy (budou perzistentní)
var story_flags: Dictionary = {
	"tutorial_call_received": false,
	"met_honza_in_pub": false,
	"first_mission_unlocked": false
}

func _ready():
	EventBus.game_state_changed.connect(_on_game_state_changed)

func _on_game_state_changed(new_state):
	if new_state == GameManager.State.ADVENTURE:
		# Odložíme kontrolu, aby se scéna stihla načíst
		get_tree().create_timer(1.0).timeout.connect(_check_story_triggers)

func _check_story_triggers():
	if not story_flags["tutorial_call_received"]:
		_trigger_first_call()

func _trigger_first_call():
	print("StoryManager: Triggering first call from Honza")
	
	# Změníme flag a uložíme (auto-save je v SaveManageru nebo manuálně)
	story_flags["tutorial_call_received"] = true
	
	# Odemkneme tutorial misi
	ProgressManager.unlock_mission("mission_tutorial")
	
	# Zvuk vyzvánění
	AudioManager.play_phone_ring()
	
	# Spustíme dialog přes EventBus
	# TODO: Přidat zvuk vyzvánění přes AudioManager
	var text = "Hej [NAME], slyšel jsem, že jseš v Mělníku. Mám pro tebe první robotu - taková ta jednoduchá. Když se osvědčíš, máme spousty peněz. Jezdi za mnou do hospody U Černého Orla, tam si promluvíme."
	
	# Dosadíme jméno hráče
	text = text.replace("[NAME]", GameManager.player_name if GameManager.player_name != "" else "parťáku")
	
	# Vytvoříme pseudo-postavu pro Honzu pro audio/vizuál
	var honza = CharacterData.new()
	honza.name = "Honza"
	honza.voice_pitch = 0.85 # Hlubší chraplák
	
	# Vyšleme požadavek na dialog
	EventBus.request_start_dialogue.emit("Honza (Telefon)", text, "res://assets/characters/honza_portrait.png", [], honza)
	
	# Uložíme postup
	SaveManager.save_game()

# --- Persistence ---
func serialize() -> Dictionary:
	return story_flags

func deserialize(data: Dictionary):
	for key in data:
		if story_flags.has(key):
			story_flags[key] = data[key]
