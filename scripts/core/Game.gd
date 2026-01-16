extends Node

@onready var thought_label: Label = $ShellLayer/GlobalUI/TopStrip/HBox/ThoughtBubble/Label
@onready var title_label: Label = $ShellLayer/GlobalUI/TopStrip/HBox/MainInfo/Title
@onready var subtitle_label: Label = $ShellLayer/GlobalUI/TopStrip/HBox/MainInfo/SubTitle
@onready var time_label: Label = $ShellLayer/GlobalUI/TopStrip/HBox/TimeWeather/TimeLabel
@onready var weather_label: Label = $ShellLayer/GlobalUI/TopStrip/HBox/TimeWeather/WeatherLabel

# Bottom Strip UI References
@onready var objective_label: Label = $ShellLayer/GlobalUI/BottomStrip/HBox/ObjectivePanel/ObjectiveText
@onready var wallet_label: Label = $ShellLayer/GlobalUI/BottomStrip/HBox/WalletPanel/WalletLabel
@onready var team_list: HBoxContainer = $ShellLayer/GlobalUI/BottomStrip/HBox/TeamStatus/TeamList

func _ready():
	print("Game.gd: _ready called")
	
	# Connect Narrative/UI signals
	if MattManager:
		MattManager.thought_emitted.connect(func(t): 
			thought_label.text = t
			print("UI: Received thought: ", t)
		)
		MattManager.emit_thought("Zase jsem tady. Mělník. Jako by se nic nezměnilo.")
	
	if TimeManager:
		TimeManager.time_changed.connect(_on_time_changed)
		_on_time_changed(TimeManager.current_slot)
		
	if WeatherManager:
		WeatherManager.weather_changed.connect(_on_weather_changed)
		_on_weather_changed(WeatherManager.current_weather)

	# Global Data Connections
	EventBus.wallet_changed.connect(_update_wallet)
	_update_wallet(EconomyManager.wallet)
	
	if has_node("/root/AdventureManager"):
		get_node("/root/AdventureManager").character_hired.connect(func(_c): _update_team_display())
	_update_team_display()

	# ... (existing internal systems setup)
	var heat_system = Node.new()
	heat_system.name = "HeatSystem"
	heat_system.set_script(load("res://scripts/systems/HeatSystem.gd"))
	add_child(heat_system)
	
	# Add Dialogue System
	var dialogue_packed = load("res://scenes/ui/DialogueSystem.tscn")
	if dialogue_packed:
		var dialogue = dialogue_packed.instantiate()
		$UILayer/UIHolder.add_child(dialogue) # Put dialogue in UI Layer
		
	# Add Phone UI for Story Events
	var phone_packed = load("res://scenes/ui/PhoneUI.tscn")
	if phone_packed:
		var phone_ui = phone_packed.instantiate()
		$UILayer/UIHolder.add_child(phone_ui)
		if has_node("/root/StoryManager"):
			get_node("/root/StoryManager").register_phone_ui(phone_ui)
	
	# Listen to GameManager state changes
	GameManager.state_changed.connect(_on_game_manager_state_changed)
	
	EventBus.request_start_game.connect(_on_start_game_requested)
	EventBus.request_quit_game.connect(_on_quit_requested)
	EventBus.request_open_mission_select.connect(func(): set_state(GameManager.State.ACTION))
	EventBus.action_phase_started.connect(_on_action_phase_started)
	
	# Connect UI signals
	EventBus.request_lockpick_minigame.connect(_on_lockpick_requested)
	EventBus.request_hacking_minigame.connect(_on_hacking_requested)
	EventBus.request_open_inventory.connect(_on_inventory_requested)
	EventBus.request_open_mission_select.connect(_on_mission_journal_requested)
	EventBus.request_open_shop.connect(_on_shop_requested)
	
	# Start in current state (persisted in GameManager)
	set_state(GameManager.current_state)

func _update_wallet(amount: int):
	wallet_label.text = str(amount) + " Kč"
	# Small animation
	var tween = create_tween()
	wallet_label.modulate = Color.GREEN
	tween.tween_property(wallet_label, "modulate", Color.WHITE, 0.5)

func _update_team_display():
	for child in team_list.get_children(): child.queue_free()
	
	var hired = []
	if has_node("/root/AdventureManager"):
		hired = get_node("/root/AdventureManager").hired_characters
		
	if hired.is_empty():
		var lbl = Label.new()
		lbl.text = "Sám na sebe."
		lbl.modulate = Color.GRAY
		team_list.add_child(lbl)
	else:
		for member in hired:
			var panel = Panel.new()
			panel.custom_minimum_size = Vector2(60, 60)
			# Placeholder for member icon
			var lbl = Label.new()
			lbl.text = member.name.left(1).to_upper()
			lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
			panel.add_child(lbl)
			team_list.add_child(panel)

func _on_time_changed(_slot):
	time_label.text = TimeManager.get_time_string()
	
func _on_weather_changed(_weather):
	weather_label.text = WeatherManager.get_weather_string()

func _on_inventory_requested():
	_show_ui_popup("res://scenes/ui/InventoryUI.tscn")

func _on_mission_journal_requested():
	_show_ui_popup("res://scenes/ui/MissionJournal.tscn")

func _on_shop_requested():
	_show_ui_popup("res://scenes/ui/ShopUI.tscn")

func _show_ui_popup(scene_path: String):
	# Don't open if already open
	for child in $UILayer/UIHolder.get_children():
		if child.scene_file_path == scene_path:
			child.queue_free()
			return
			
	var packed = load(scene_path)
	if packed:
		var popup = packed.instantiate()
		$UILayer/UIHolder.add_child(popup)

func _on_game_manager_state_changed(new_state: GameManager.State):
	set_state(new_state)

func _on_action_phase_started(plan: PlanningData):
	print("Game.gd: Action Phase Started!")
	# Manually handle the transition to ensure we pass the plan
	GameManager.current_state = GameManager.State.ACTION
	
	# Clear containers
	for child in $WorldHolder.get_children(): child.queue_free()
	for child in $PlanningHolder.get_children(): child.queue_free()
	for child in $UILayer/UIHolder.get_children(): child.queue_free()
	
	# Load Action Mode
	var action_packed = load("res://scenes/core/ActionMode.tscn")
	if action_packed:
		var action_mode = action_packed.instantiate()
		$WorldHolder.add_child(action_mode)
		action_mode.setup_execution(plan)
		
	EventBus.game_state_changed.emit(GameManager.State.ACTION)

func _on_lockpick_requested(difficulty: float, callback: Callable):
	_show_minigame("res://scenes/ui/Minigame_Lockpick.tscn", difficulty, callback)

func _on_hacking_requested(difficulty: float, callback: Callable):
	_show_minigame("res://scenes/ui/Minigame_Hacking.tscn", difficulty, callback)

func _show_minigame(scene_path: String, difficulty: float, callback: Callable):
	var packed = load(scene_path)
	if packed:
		var minigame = packed.instantiate()
		$UILayer/UIHolder.add_child(minigame)
		if minigame.has_method("setup"):
			minigame.setup(difficulty, callback)

func close_current_ui():
	for child in $UILayer/UIHolder.get_children():
		child.queue_free()

func _on_start_game_requested():
	print("Game.gd: Start game requested")
	set_state(GameManager.State.ADVENTURE)

func _on_quit_requested():
	get_tree().quit()

func set_state(new_state):
	print("Game.gd: Setting state to ", new_state)
	GameManager.current_state = new_state
	
	# Clear containers
	for child in $WorldHolder.get_children(): child.queue_free()
	for child in $PlanningHolder.get_children(): child.queue_free()
	for child in $UILayer/UIHolder.get_children(): child.queue_free()

	match GameManager.current_state:
		GameManager.State.MENU:
			var menu_packed = load("res://scenes/ui/MainMenu.tscn")
			if menu_packed:
				$UILayer/UIHolder.add_child(menu_packed.instantiate())
			
		GameManager.State.ADVENTURE:
			print("Game.gd: Loading AdventureMode (Container)...")
			title_label.text = "ULICE MĚLNÍKA"
			subtitle_label.text = "Hledání kontaktů a tipů"
			var adv_packed = load("res://scenes/core/AdventureMode.tscn")
			if adv_packed:
				$WorldHolder.add_child(adv_packed.instantiate())
				
		GameManager.State.HIDEOUT:
			print("Game.gd: Loading HideoutMode (Hotel)...")
			title_label.text = "HOTEL AUGUSTINE"
			subtitle_label.text = "Bezpečné místo pro plánování"
			var hide_packed = load("res://scenes/core/HideoutMode.tscn")
			if hide_packed:
				$WorldHolder.add_child(hide_packed.instantiate())
				
		GameManager.State.PLANNING:
			print("Game.gd: Loading PlanningMode (Heist Editor)...")
			title_label.text = "TAKTICKÝ PLÁN"
			subtitle_label.text = "Synchronizace týmu"
			var plan_packed = load("res://scenes/core/PlanningMode.tscn")
			if plan_packed:
				$PlanningHolder.add_child(plan_packed.instantiate())
				
		GameManager.State.ACTION:
			# Handled by _on_action_phase_started mainly, but if accessed directly:
			if $WorldHolder.get_child_count() == 0:
				var heist_packed = load("res://scenes/core/ActionMode.tscn")
				if heist_packed:
					$WorldHolder.add_child(heist_packed.instantiate())
					
		GameManager.State.RESULTS:
			print("Game.gd: Loading ResultScreen...")
			var results_packed = load("res://scenes/ui/ResultScreen.tscn")
			if results_packed:
				$UILayer/UIHolder.add_child(results_packed.instantiate())
	
	EventBus.game_state_changed.emit(new_state)

func _unhandled_input(event):
	if event.is_action_pressed("switch_to_planning"):
		if GameManager.current_state == GameManager.State.ADVENTURE:
			set_state(GameManager.State.PLANNING)
	elif event.is_action_pressed("switch_to_adventure"):
		if GameManager.current_state == GameManager.State.PLANNING:
			set_state(GameManager.State.ADVENTURE)
	elif event.is_action_pressed("open_inventory"):
		EventBus.request_open_inventory.emit()
	elif event.is_action_pressed("open_mission_select"):
		EventBus.request_open_mission_select.emit()
	elif event.is_action_pressed("open_shop"):
		EventBus.request_open_shop.emit()
	elif event.is_action_pressed("ui_cancel"):
		if GameManager.current_state != GameManager.State.MENU:
			set_state(GameManager.State.MENU)
