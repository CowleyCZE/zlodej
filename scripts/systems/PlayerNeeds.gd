# PlayerNeeds.gd
extends Node

var money: int = 1000
var health: int = 100
var reputation: int = 0
var heat_level: int = 0 # police searching

func update_needs(_delta: float):
	# logic for degradation or heat increase
	if heat_level > 80:
		trigger_police_raid()

func trigger_police_raid():
	pass
