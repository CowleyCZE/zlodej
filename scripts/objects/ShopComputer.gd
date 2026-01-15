extends StaticBody3D

func interact(_player):
	print("Opening Shop...")
	EventBus.request_open_shop.emit()
