extends StaticBody3D

func interact(_player):
	print("Opening Mission Selection...")
	EventBus.request_open_mission_select.emit()
