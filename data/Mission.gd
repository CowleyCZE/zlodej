# res://Data/Mission.gd
extends Resource
# class_name Mission

@export var id: String
@export var region_id: String
@export var name: String
@export var description: String
@export var difficulty: int
@export var min_reputation: int
@export var reward: int
@export var intel_level: float = 0.0 # 0.0 to 100.0
