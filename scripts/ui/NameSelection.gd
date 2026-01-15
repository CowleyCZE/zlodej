class_name NameSelection
extends Control

@onready var name_input: LineEdit = $Panel/VBoxContainer/NameInput
@onready var confirm_button: Button = $Panel/VBoxContainer/ConfirmButton

var random_names: Array[String] = [
	"Petr", "Pavel", "Jan", "Tomáš", "Lukáš", "Michal", 
	"David", "Jakub", "Martin", "Jiří", "Shadow", "Ghost"
]

func _ready() -> void:
	confirm_button.disabled = true
	name_input.text_changed.connect(_on_text_changed)
	confirm_button.pressed.connect(_on_confirm_pressed)
	$Panel/VBoxContainer/RandomButton.pressed.connect(_on_random_pressed)
	
	name_input.grab_focus()

func _on_text_changed(new_text: String) -> void:
	confirm_button.disabled = new_text.strip_edges().is_empty()

func _on_random_pressed() -> void:
	name_input.text = random_names.pick_random()
	confirm_button.disabled = false

func _on_confirm_pressed() -> void:

	var final_name = name_input.text.strip_edges()

	if not final_name.is_empty():

		GameManager.set_player_name(final_name)

		

		# DŮLEŽITÉ: Nastavíme stav na ADVENTURE, ale musíme načíst hlavní scénu hry (Game.tscn)

		# Samotný GameManager signál nestačí, protože Game.gd (listener) teď neběží.

		GameManager.current_state = GameManager.State.ADVENTURE

		get_tree().change_scene_to_file("res://scenes/core/Game.tscn")
