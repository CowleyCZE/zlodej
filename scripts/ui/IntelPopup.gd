class_name IntelPopup
extends Control

signal planning_started(mission_data)

# Nodes (Assumed structure)
@onready var panel = $Panel
@onready var lbl_mission_name = $Panel/VBox/MissionName
@onready var lbl_percentage = $Panel/VBox/TotalPercent
@onready var items_container = $Panel/VBox/Scroll/ItemsContainer
@onready var btn_start = $Panel/VBox/Btn_Start
@onready var btn_close = $Panel/Btn_Close

var current_mission: MissionData

func _ready():
	if btn_start:
		btn_start.pressed.connect(_on_start_pressed)
	if btn_close:
		btn_close.pressed.connect(_on_close_pressed)

func setup(mission: MissionData):
	current_mission = mission
	if lbl_mission_name:
		lbl_mission_name.text = mission.name
	_refresh_ui()

func _refresh_ui():
	if not current_mission: return
	
	var total = current_mission.get_total_intel_percentage()
	if lbl_percentage:
		lbl_percentage.text = "ZÍSKANÉ INFORMACE: %d%%" % (total * 100)
		if total < 0.5:
			lbl_percentage.modulate = Color.RED
		else:
			lbl_percentage.modulate = Color.GREEN
	
	# Refresh Items
	if items_container:
		for child in items_container.get_children():
			child.queue_free()
			
		for key in current_mission.intel_flags.keys():
			var has_intel = current_mission.intel_flags[key]
			var row = HBoxContainer.new()
			
			var lbl = Label.new()
			var translated_key = key
			match key:
				"architecture": translated_key = "Architektura"
				"patrols": translated_key = "Hlídky"
				"security": translated_key = "Zabezpečení"
				"treasure": translated_key = "Cíl (Kořist)"
				"routes": translated_key = "Cesty a únik"
			
			lbl.text = translated_key
			lbl.custom_minimum_size.x = 150
			row.add_child(lbl)
			
			if has_intel:
				var status = Label.new()
				status.text = "ZÍSKÁNO"
				status.modulate = Color.GREEN
				row.add_child(status)
			else:
				var btn_buy = Button.new()
				var method_name = "ZÍSKAT"
				match key:
					"architecture": method_name = "KOUPIT PLÁNY"
					"patrols": method_name = "UPLATIT STRÁŽ"
					"security": method_name = "HACKNOUT KAMERY"
					"treasure": method_name = "INFORMÁTOR"
					"routes": method_name = "PRŮZKUM"
				
				var IntelSystem = load("res://scripts/systems/IntelligenceGatheringSystem.gd")
				var cost = IntelSystem.get_cost(key)
				var heat = IntelSystem.get_heat_risk(key)
				
				var cost_text = "%d CZK" % cost if cost > 0 else "ZDARMA"
				btn_buy.text = "%s (%s, +%.0f Heat)" % [method_name, cost_text, heat]
				
				# Disable if too expensive
				if EconomyManager.wallet < cost:
					btn_buy.disabled = true
					
				btn_buy.pressed.connect(_on_buy_intel.bind(key))
				row.add_child(btn_buy)
				
			items_container.add_child(row)
			
	if btn_start:
		btn_start.disabled = (total < 0.5)
		if btn_start.disabled:
			btn_start.text = "VYŽADUJE 50% INFORMACÍ"
		else:
			btn_start.text = "ZAČÍT PLÁNOVÁNÍ"

func _on_buy_intel(category: String):
	var IntelSystem = load("res://scripts/systems/IntelligenceGatheringSystem.gd")
	if IntelSystem.try_gather_intel(current_mission, category):
		_refresh_ui()
	else:
		# Feedback handled by system (print) or we could show a popup here
		pass

func _on_start_pressed():
	if current_mission:
		planning_started.emit(current_mission)
	queue_free()

func _on_close_pressed():
	queue_free()
