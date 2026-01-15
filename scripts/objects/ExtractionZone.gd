extends Area2D

# When all active agents are inside, trigger extraction
var agents_in_zone: Array = []

func _ready():
	add_to_group("extraction_zone")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Visual setup
	modulate = Color(0, 1, 0, 0.3)

func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		if not body in agents_in_zone:
			agents_in_zone.append(body)
			_check_all_extracted()

func _on_body_exited(body: Node2D):
	if body in agents_in_zone:
		agents_in_zone.erase(body)

func _physics_process(_delta):
	if not agents_in_zone.is_empty():
		_check_all_extracted()

func _check_all_extracted():
	# In a real scenario, we might require ALL living agents.
	# For MVP, if ANY agent enters with the loot (or just enters), we can trigger logic.
	
	if GameManager.main_loot_collected:
		# Prevent multiple triggers
		set_physics_process(false)
		print("Extraction Zone: Loot collected and team present, triggering extraction!")
		EventBus.mission_completed.emit(GameManager.current_mission.mission_id if GameManager.current_mission else "unknown")
