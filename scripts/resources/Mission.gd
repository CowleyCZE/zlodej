# Mission.gd
class_name Mission extends Resource

@export var objectives: Array[String]
@export var location_id: String
@export var time_limit: float # min
@export var required_tools: Array[String]
@export var accomplices_needed: int

func execute():
	# Logic for mission execution
	pass
