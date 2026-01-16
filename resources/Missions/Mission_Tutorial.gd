extends MissionData

func _init():
	mission_id = "mission_tutorial"
	name = "Malý zkoušební lup"
	description = "Skřehky 'vypůjčený' klíč ke skladu MelTech s.r.o. Jednoduchá práce pro zahřátí."
	briefing = "MelTech s.r.o. má ve svém skladu starý terminál s cennými daty. Tvůj úkol je prostý: Dostaň se dovnitř, stáhni data na disk a zmiz, než si toho někdo všimne.\n\nTip: Honza říkal, že zadní vchod bývá v noci špatně hlídaný."
	
	region_id = "melnik_industrial"
	target_location = "res://scenes/levels/Level_Tutorial.tscn"
	
	difficulty = 1
	min_reputation = 0
	base_reward = 5000
	reputation_gain = 20
	
	objective_type = "steal_item"
	objective_item = "Digitální Disk"
	
	# Zabezpečení
	guard_count = 1
	camera_count = 1
	has_alarm = false # Pro tutorial vypnuto
	
	# Požadavky
	required_tools = ["lockpick_set"]
	max_team_size = 2
	time_limit_seconds = 300.0 # 5 minut
	
	# Tutorial Intel (Hráč začíná s určitou znalostí)
	intel_flags = {
		"architecture": true,
		"patrols": false,
		"security": false,
		"treasure": true, # Víme kde to je
		"routes": true # Víme kudy tam
	}
	
	known_facts = {
		"back_door": "Zadní vchod: Zámek je starý a rezavý (Level 1).",
		"guard_routine": "Stráž 'Lojza': Většinu času spí v kukani."
	}
