class_name AlarmButton
extends InteractiveObject

@onready var sprite = $Sprite2D
@export var is_active: bool = true

func _ready():
	object_name = "Alarm Button"
	add_to_group("alarm_triggers")

func _on_interact(agent: Node) -> void:
	if not is_active: return
	
	if agent.is_in_group("guards") or agent.is_in_group("player"):
		AlarmManager.trigger_alarm(global_position)
		_visual_feedback()

func _visual_feedback():
	# Simple visual pop or color change
	if sprite:
		var tween = create_tween()
		tween.tween_property(sprite, "modulate", Color.RED, 0.2)
		tween.tween_property(sprite, "modulate", Color.WHITE, 0.2)
