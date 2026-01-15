extends Node2D

@onready var btn_pub: Button = $UI/Locations/Btn_Pub
@onready var btn_cafe: Button = $UI/Locations/Btn_Cafe
@onready var btn_hotel: Button = $UI/Locations/Btn_Hotel
@onready var btn_start_mission: Button = $UI/Locations/Btn_StartMission
@onready var money_label: Label = $UI/HUD_Panel/VBox/MoneyLabel
@onready var team_label: Label = $UI/HUD_Panel/VBox/TeamLabel

func _ready() -> void:
	# Update UI
	_update_hud()
	
	# Connect Signals
	btn_pub.pressed.connect(_on_pub_pressed)
	btn_cafe.pressed.connect(_on_cafe_pressed)
	btn_hotel.pressed.connect(_on_hotel_pressed)
	btn_start_mission.pressed.connect(_on_start_mission_pressed)
	
	# Listen to global events
	EventBus.character_hired.connect(func(_char): _update_hud())

func _update_hud() -> void:
	money_label.text = "Finance: %d CZK" % EconomyManager.wallet
	team_label.text = "Tým: %d" % AdventureManager.hired_characters.size()

func _on_pub_pressed() -> void:
	print("Vstup do Hospody U Orla...")
	# TODO: Open Recruitment UI
	
func _on_cafe_pressed() -> void:
	print("Vstup do Café Vltava...")
	# TODO: Open Intel UI

func _on_hotel_pressed() -> void:
	print("Návrat na hotel...")

func _on_start_mission_pressed() -> void:
	print("Startuji Tutorial Misi...")
	# Load mission data
	var mission = load("res://resources/Missions/Mission_Tutorial.tres")
	if mission:
		# Notify system about mission start
		EventBus.planning_activated.emit(mission)
		# Switch state
		GameManager.change_state(GameManager.State.PLANNING)
