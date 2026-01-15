class_name StoryEvent
extends Resource

# Základní info
@export var event_id: String
@export var title: String # Např. "Příchozí hovor: Honza"
@export var is_phone_call: bool = true

# Obsah
@export var character_name: String = "Honza"
@export var character_portrait: Texture2D
@export_multiline var dialogue_text: String
@export var audio_clip: AudioStream

# Podmínky spuštění
@export_group("Conditions")
@export var required_mission_completed: String = "" # ID mise, která musí být hotová
@export var required_reputation: int = 0
@export var trigger_delay_seconds: float = 2.0 # Zpoždění po splnění podmínek

# Efekty po dokončení
@export_group("Effects")
@export var unlock_mission_id: String = ""
@export var add_money: int = 0
@export var add_reputation: int = 0
@export var set_story_flag: String = "" # Nastaví tento flag na true ve StoryManageru
