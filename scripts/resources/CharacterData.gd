class_name CharacterData
extends Resource

# Identita
@export var name: String
@export var age: int
@export var portrait: Texture2D
@export_multiline var description: String
@export_multiline var greeting_text: String # New: Dialog when meeting in location

# Rozvrh (Schedule)
# Klíče: "morning" (6-12), "day" (12-18), "evening" (18-24), "night" (0-6)
# Hodnoty: ID lokace (např. "CernyOrel") nebo "" (nedostupný/doma)
@export var schedule: Dictionary = {
	"morning": "",
	"day": "",
	"evening": "CernyOrel",
	"night": "CernyOrel"
}

# Profesní
@export var role: String # driver, hacker, thief...
@export var hiring_cost: float = 5000.0 # Requirement 2: Záloha (Upfront cost)
@export var loot_share_percent: int = 15 # Requirement 2: Podíl z výnosu (0-100%)
@export var daily_salary: float = 0.0
@export var expected_payment: float = 0.0

# Dovednosti (0-100)
@export var driving: int = 50
@export var lock_picking: int = 50
@export var electronics: int = 50
@export var stealth: int = 50
@export var strength: int = 50

# Osobnostní rysy (0.0 - 100.0)
@export var greed: float = 50.0       # Jak moc si vezme
@export var loyalty: float = 50.0     # Zůstane s vámi?
@export var nerves: float = 50.0      # Stabilita pod tlakem
@export var dexterity: float = 50.0   # Obratnost

# Stav
@export var is_hirable: bool = true
@export var is_hired: bool = false
@export var is_injured: bool = false
@export var injury_level: float = 0.0 # 0.0 - 1.0
@export var fatigue: float = 0.0
@export var stress: float = 0.0
@export var satisfaction: float = 0.0 # Ovlivňuje loajalitu

# Audio (Barks/Dialogue)
@export var voice_pitch: float = 1.0 # 0.8 to 1.2
@export var greeting_audio: AudioStream # Snippet played when dialogue starts

# Vybavení (NEW) - Bod 3: Nákup a správa vybavení
@export var inventory: Array[String] = [] # List of item IDs (e.g. "lockpick_kit", "crowbar")

func has_item(item_id: String) -> bool:
	return inventory.has(item_id)

func add_item(item_id: String) -> void:
	inventory.append(item_id)

func remove_item(item_id: String) -> bool:
	if has_item(item_id):
		inventory.erase(item_id)
		return true
	return false