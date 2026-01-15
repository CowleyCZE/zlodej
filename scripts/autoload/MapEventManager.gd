# MapEventManager.gd (Autoload)
extends Node

enum EventType { NONE, POLICE_RAID, INTEL_SALE, MARKET_SALE }

# { location_id: { "type": EventType, "value": float, "duration": int } }
var active_events: Dictionary = {}

signal events_updated

func _ready():
	TimeManager.time_changed.connect(_on_time_changed)
	# Initial generation
	_generate_random_events()

func _on_time_changed(_new_slot):
	_generate_random_events()

func _generate_random_events():
	active_events.clear()
	
	var locations = ["CernyOrel", "CafeVltava", "Staveniste", "PodBrehem"]
	
	# 1. Chance for Police Raid (20%)
	if randf() < 0.2:
		var loc = locations.pick_random()
		active_events[loc] = {
			"type": EventType.POLICE_RAID,
			"label": "POLICEJNÍ ZÁTAH",
			"description": "Oblast je pod dohledem. Vstup zvýší tvůj Heat!",
			"heat_penalty": 20.0
		}
		print("EVENT: Police Raid at ", loc)

	# 2. Chance for Intel Sale (30%)
	if randf() < 0.3:
		var loc = locations.pick_random()
		if not active_events.has(loc):
			active_events[loc] = {
				"type": EventType.INTEL_SALE,
				"label": "TIP OD INFORMANTA",
				"description": "Místní kontakt nabízí horké informace se slevou.",
				"discount": 0.5
			}
			print("EVENT: Intel Sale at ", loc)

	events_updated.emit()

func get_event_for(location_id: String) -> Dictionary:
	return active_events.get(location_id, {})

func has_event(location_id: String) -> bool:
	return active_events.has(location_id)
