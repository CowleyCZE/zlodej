# ThinkPanel.gd
extends Control

@onready var team_list = $Panel/VBoxContainer/TeamList
@onready var finance_label = $Panel/VBoxContainer/FinanceLabel
@onready var mission_label = $Panel/VBoxContainer/MissionLabel
@onready var intel_progress = $Panel/VBoxContainer/IntelProgress
@onready var intel_label = $Panel/VBoxContainer/IntelLabel

func _ready():
	visible = false
	update_panel()
	
	if has_node("/root/IntelManager"):
		get_node("/root/IntelManager").intel_gathered.connect(func(_id, _amt, _total): update_panel())
	
	if has_node("/root/AdventureManager"):
		get_node("/root/AdventureManager").character_hired.connect(func(_char): update_panel())

func toggle():
	visible = !visible
	if visible:
		update_panel()

func update_panel():
	# Finance
	finance_label.text = "Finance: " + str(EconomyManager.wallet) + " Kč"
	
	# Team
	for child in team_list.get_children():
		child.queue_free()
	
	if AdventureManager.hired_characters.is_empty():
		var l = Label.new()
		l.text = "Žádní specialisté"
		l.add_theme_color_override("font_color", Color.GRAY)
		team_list.add_child(l)
	else:
		for c in AdventureManager.hired_characters:
			var l = Label.new()
			l.text = "• " + c.name + " (" + c.role + ")"
			team_list.add_child(l)
			
	# Mission
	if GameManager.selected_mission:
		mission_label.text = "Mise: " + GameManager.selected_mission.name
		var intel = GameManager.selected_mission.intel_level
		intel_progress.value = intel
		intel_label.text = "Informace: " + str(int(intel)) + "%"
		if intel < 50.0:
			intel_label.text += " (Vyžadováno 50%)"
		else:
			intel_label.text += " (READY)"
	else:
		mission_label.text = "Mise: Žádná vybraná"
		intel_progress.value = 0
		intel_label.text = "Informace: 0%"

func _on_close_button_pressed():
	visible = false
