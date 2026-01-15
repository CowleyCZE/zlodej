extends Node

func _ready():
	print("Game.gd: _ready called")
	
	# Add internal systems
	var heat_system = Node.new()
	heat_system.name = "HeatSystem"
	heat_system.set_script(load("res://scripts/systems/HeatSystem.gd"))
	add_child(heat_system)
	
	# Add Dialogue System
	var dialogue_packed = load("res://scenes/ui/DialogueSystem.tscn")
	if dialogue_packed:
		var dialogue = dialogue_packed.instantiate()
		$CanvasLayer.add_child(dialogue)
		
	# Add Phone UI for Story Events
	var phone_packed = load("res://scenes/ui/PhoneUI.tscn")
	if phone_packed:
		var phone_ui = phone_packed.instantiate()
		$CanvasLayer.add_child(phone_ui)
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

func _on_inventory_requested():
	_show_ui_popup("res://scenes/ui/InventoryUI.tscn")

func _on_mission_journal_requested():
	_show_ui_popup("res://scenes/ui/MissionJournal.tscn")

func _on_shop_requested():
	_show_ui_popup("res://scenes/ui/ShopUI.tscn")

func _show_ui_popup(scene_path: String):
	# Don't open if already open
	for child in $CanvasLayer/UIHolder.get_children():
		if child.scene_file_path == scene_path:
			child.queue_free()
			return
			
	var packed = load(scene_path)
	if packed:
		var popup = packed.instantiate()
		$CanvasLayer/UIHolder.add_child(popup)

func _on_game_manager_state_changed(new_state: GameManager.State):
	set_state(new_state)

func _on_action_phase_started(plan: PlanningData):
	print("Game.gd: Action Phase Started!")
	# Manually handle the transition to ensure we pass the plan
	GameManager.current_state = GameManager.State.ACTION
	
	# Clear containers
	for child in $WorldHolder.get_children(): child.queue_free()
	for child in $PlanningHolder.get_children(): child.queue_free()
	for child in $CanvasLayer/UIHolder.get_children(): child.queue_free()
	
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
		$CanvasLayer/UIHolder.add_child(minigame)
		if minigame.has_method("setup"):
			minigame.setup(difficulty, callback)

func close_current_ui():
	for child in $CanvasLayer/UIHolder.get_children():
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
	for child in $CanvasLayer/UIHolder.get_children(): child.queue_free()

	match GameManager.current_state:
		GameManager.State.MENU:
			var menu_packed = load("res://scenes/ui/MainMenu.tscn")
			if menu_packed:
				$CanvasLayer/UIHolder.add_child(menu_packed.instantiate())
			
		GameManager.State.ADVENTURE:
			print("Game.gd: Loading AdventureMode (Container)...")
			var adv_packed = load("res://scenes/core/AdventureMode.tscn")
			if adv_packed:
				$WorldHolder.add_child(adv_packed.instantiate())
				
		GameManager.State.PLANNING:
			print("Game.gd: Loading PlanningMode (Heist Editor)...")
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
				$CanvasLayer/UIHolder.add_child(results_packed.instantiate())
	
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
