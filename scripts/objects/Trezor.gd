extends InteractiveObject

class_name Trezor

@export var is_locked: bool = true
@export var lock_level: int = 3
@export var loot_value: int = 10000

func _ready():
	super._ready()
	object_name = "Trezor"
	available_actions = ["Vrtat", "Páčit"]

func on_timeline_action_completed(action_name: String):
	if not is_locked:
		return

	if action_name == "Vrtat" or action_name == "Páčit":
		print(object_name, " byl otevřen.")
		is_locked = false
		
		# Po otevření se zpřístupní akce "Sebrat"
		if "Vrtat" in available_actions:
			available_actions.erase("Vrtat")
		if "Páčit" in available_actions:
			available_actions.erase("Páčit")
		if not "Sebrat" in available_actions:
			available_actions.append("Sebrat")
			
		# Změníme vizuální stav (až bude sprite)
		modulate = Color(0.7, 1.0, 0.7) 
	
	# Zpracování sebrání lupu je už v InteractiveObject
	super.on_timeline_action_completed(action_name)
