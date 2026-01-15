extends Node2D

var timestamp: float = 0.0
var distance_on_path: float = 0.0

@onready var label: Label = $TimeLabel
@onready var visual: Sprite2D = $Visual

func setup(pos: Vector2, time: float, dist: float):
	position = pos
	timestamp = time
	distance_on_path = dist
