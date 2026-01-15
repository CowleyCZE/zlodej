extends InteractiveObject

@export var is_locked: bool = false
var is_open: bool = false

@onready var static_body: StaticBody2D = $StaticBody2D
@onready var visual_closed: ColorRect = $Visuals/Closed
@onready var visual_open: ColorRect = $Visuals/Open

func _ready() -> void:
	if is_locked and required_tool == "":
		required_tool = "lockpick"
	_update_state()

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