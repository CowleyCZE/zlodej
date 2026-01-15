# AdventureManager.gd (Autoload)
extends Node

var hired_characters: Array[CharacterData] = []
var available_characters: Array[CharacterData] = []

signal character_hired(character: CharacterData)

func _ready():
	# Inicializace dostupných postav (Josefa, Petru, Milana)
	_load_available_characters()

func _load_available_characters():
	var paths = [
		"res://resources/Characters/Josef.tres",
		"res://resources/Characters/Petra.tres",
		"res://resources/Characters/Milan.tres",
		"res://resources/Characters/Anna.tres",
		"res://resources/Characters/Vojtech.tres",
		"res://resources/Characters/Honza.tres"
	]
	
	for path in paths:
		if ResourceLoader.exists(path):
			var char_data = load(path)
			if char_data is CharacterData:
				available_characters.append(char_data)

func hire_character(char_data: CharacterData) -> bool:
	if char_data in hired_characters:
		print("Postava ", char_data.name, " už je v týmu.")
		return false
		
	if EconomyManager.wallet >= char_data.hiring_cost:
		EconomyManager.wallet -= int(char_data.hiring_cost)
		hired_characters.append(char_data)
		character_hired.emit(char_data)
		SaveManager.save_game()
		print("Najata postava: ", char_data.name)
		return true
	else:
		print("Nedostatek peněz na najmutí: ", char_data.name)
		return false

func is_hired(char_name: String) -> bool:
	for c in hired_characters:
		if c.name == char_name:
			return true
	return false

func get_characters_in_location(location_id: String) -> Array[CharacterData]:
	var result: Array[CharacterData] = []
	var time_key = TimeManager.get_schedule_key()
	
	for char_data in available_characters:
		# Pokud je najmutá, nezobrazuje se v lokaci (nebo se zobrazuje jinak - to vyřešíme v UI)
		if char_data in hired_characters:
			continue
			
		# Kontrola rozvrhu
		var scheduled_loc = char_data.schedule.get(time_key, "")
		
		# Fallback pro staré resource soubory (pokud schedule chybí)
		if scheduled_loc == null:
			# Použijeme starý spawn_location, pokud existuje (jen pro kompatibilitu)
			if "spawn_location" in char_data and char_data.spawn_location == location_id:
				result.append(char_data)
			continue
			
		if scheduled_loc == location_id:
			result.append(char_data)
			
	return result
