class_name MissionJournal
extends Control

@onready var mission_list = $Panel/Layout/LeftColumn/Scroll/MissionList
@onready var detail_title = $Panel/Layout/RightColumn/MissionTitle
@onready var detail_briefing = $Panel/Layout/RightColumn/ScrollBrief/BriefingText
@onready var intel_container = $Panel/Layout/RightColumn/IntelSection/Grid
@onready var btn_plan = $Panel/Layout/RightColumn/Btn_StartPlanning

var selected_mission: MissionData

func _ready():
	_refresh_mission_list()
	EventBus.game_state_changed.connect(func(_s): _refresh_mission_list())
	$Panel/Btn_Close.pressed.connect(queue_free)
	btn_plan.pressed.connect(_on_plan_pressed)

func _refresh_mission_list():
	for child in mission_list.get_children():
		child.queue_free()
	
	# Load tutorial mission as default for now
	var tutorial = load("res://resources/Missions/Mission_Tutorial.tres")
	if tutorial:
		_add_mission_entry(tutorial)

func _add_mission_entry(mission: MissionData):
	var btn = Button.new()
	btn.text = mission.name
	btn.custom_minimum_size.y = 50
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.pressed.connect(_on_mission_selected.bind(mission))
	mission_list.add_child(btn)

func _on_mission_selected(mission: MissionData):
	selected_mission = mission
	detail_title.text = mission.name
	detail_briefing.text = mission.briefing
	
	_update_intel_display(mission)
	
	# Show Start Planning if intel >= 50%
	btn_plan.visible = true
	btn_plan.disabled = mission.get_total_intel_percentage() < 0.5
	if btn_plan.disabled:
		btn_plan.text = "NEDOSTATEK INFORMACÍ (MIN 50%)"
	else:
		btn_plan.text = "PŘEJÍT K PLÁNOVÁNÍ"

func _update_intel_display(mission: MissionData):
	for child in intel_container.get_children():
		child.queue_free()
		
	for key in mission.intel_flags.keys():
		var lbl = Label.new()
		var has_it = mission.intel_flags[key]
		lbl.text = "• " + key.capitalize()
		lbl.modulate = Color.GREEN if has_it else Color.GRAY
		intel_container.add_child(lbl)

func _on_plan_pressed():
	if selected_mission:
		# Emit same logic as map but from journal
		var map = get_tree().root.find_child("WorldMap2D", true, false)
		if map and map.has_method("_start_planning"):
			map._start_planning(selected_mission)
			queue_free()
		else:
			# Fallback if map not present
			EventBus.planning_activated.emit(selected_mission)
			GameManager.change_state(GameManager.State.PLANNING)
			queue_free()
