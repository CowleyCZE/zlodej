extends Control

@onready var info_panel = $MissionInfoPanel
@onready var mission_title = $MissionInfoPanel/VBox/MissionTitle
@onready var reward_label = $MissionInfoPanel/VBox/RewardLabel

var selected_mission_id = ""
var missions = {
	"hotel": {
		"title": "Loupež v Hotelu Augustine",
		"reward": "80 000 Kč",
		"level_path": "res://scenes/levels/Level_HotelAugustine.tscn"
	},
	"warehouse": {
		"title": "Sklad v Hostivaři",
		"reward": "25 000 Kč",
		"level_path": "res://scenes/levels/Level_Warehouse_Small.tscn"
	}
}

func _ready():
	info_panel.visible = false
	
	$PinsContainer/Pin_Hotel.pressed.connect(func(): _show_mission("hotel"))
	$PinsContainer/Pin_Bank.pressed.connect(func(): _show_mission("warehouse")) # Pin_Bank used for warehouse for now
	
	$MissionInfoPanel/VBox/Btn_StartMission.pressed.connect(_on_Btn_StartMission_pressed)
	$MissionInfoPanel/VBox/Btn_ClosePanel.pressed.connect(_on_Btn_ClosePanel_pressed)
	$Btn_BackToHub.pressed.connect(_on_Btn_BackToHub_pressed)

func _show_mission(id):
	selected_mission_id = id
	var data = missions[id]
	mission_title.text = data.title
	reward_label.text = "Odměna: " + data.reward
	info_panel.visible = true

func _on_Btn_StartMission_pressed():
	if selected_mission_id != "":
		var data = missions[selected_mission_id]
		# Tell Game.gd to load this level and switch to Adventure or Planning
		# For simplicity, let's jump to Planning mode first as per GDD
		EventBus.mission_started.emit(selected_mission_id)
		
		# Close UI
		get_tree().get_root().get_node("Main").close_current_ui()
		
		# We might need to store the level_path somewhere global so AdventureMode knows what to load
		# Let's put it in GameManager for now
		if GameManager.has_method("set_current_level"):
			GameManager.set_current_level(data.level_path)
		
		# Switch to planning state
		var game = get_tree().get_root().find_child("Game", true, false)
		if game:
			game.set_state(GameManager.GameState.PLANNING)

func _on_Btn_ClosePanel_pressed():
	info_panel.visible = false

func _on_Btn_BackToHub_pressed():
	get_tree().get_root().get_node("Main").close_current_ui()
