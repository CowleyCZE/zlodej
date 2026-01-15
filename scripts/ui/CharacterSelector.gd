extends HBoxContainer

signal character_selected(char_id: String)

func _ready():
	# Zajistíme, že tlačítka chytají myš
	$Thief.mouse_filter = Control.MOUSE_FILTER_STOP
	$Hacker.mouse_filter = Control.MOUSE_FILTER_STOP
	# Výchozí stav
	$Thief.modulate = Color(1, 1, 1, 1)
	$Hacker.modulate = Color(0.5, 0.5, 0.5, 1)

func _on_thief_pressed():
	print("UI: Kliknuto na JOSEF")
	character_selected.emit("josef")
	$Thief.modulate = Color(1, 1, 1, 1)
	$Hacker.modulate = Color(0.5, 0.5, 0.5, 1)

func _on_hacker_pressed():
	print("UI: Kliknuto na PETRA")
	character_selected.emit("petra")
	$Thief.modulate = Color(0.5, 0.5, 0.5, 1)
	$Hacker.modulate = Color(1, 1, 1, 1)
