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
