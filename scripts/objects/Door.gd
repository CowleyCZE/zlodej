extends InteractiveObject

@export var is_locked: bool = false
@export var remote_group_id: String = "" # e.g. "server_room"
var is_open: bool = false

@onready var static_body: StaticBody2D = $StaticBody2D
@onready var visual_closed: ColorRect = $Visuals/Closed
@onready var visual_open: ColorRect = $Visuals/Open

func _ready() -> void:
	if is_locked and required_tool == "":
		required_tool = "lockpick"
	_update_state()
	
	if remote_group_id != "":
		EventBus.request_remote_unlock.connect(_on_remote_unlock)

func _on_remote_unlock(group_id: String) -> void:
	if is_locked and group_id == remote_group_id:
		unlock()

func unlock() -> void:
	is_locked = false
	required_tool = ""
	print("DOOR: Remotely unlocked ", object_name)
	# Optional: Visual feedback (blink LED)
	
func _on_interact(_agent: Node) -> void:
	# Note: Tool validation happens in parent InteractiveObject.interact()
	is_open = !is_open
	_update_state()

func _update_state() -> void:
	# Physics
	static_body.process_mode = Node.PROCESS_MODE_DISABLED if is_open else Node.PROCESS_MODE_INHERIT
	
	# Visuals
	visual_closed.visible = !is_open
	visual_open.visible = is_open
	
	# Future: Update Occluder logic here