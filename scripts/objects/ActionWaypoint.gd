extends Node2D

@onready var sprite = $Sprite2D
@onready var label = $Label

func setup(action_name: String, duration: float, position: Vector2, icon_texture: Texture2D = null):
	sself.global_position = position
	if icon_texture:
		sprite.texture = icon_texture
	else:
		# TODO: Nastavit defaultní ikonu nebo ikonu podle typu akce
		pass
	
	label.text = action_name.split(" ")[0] + "\n" + str(duration) + "s"
	if action_name == "Čekat":
		sprite.modulate = Color(0.8, 0.8, 0.2) # Žlutá pro čekání
	else:
		sprite.modulate = Color(1.0, 1.0, 1.0) # Reset barvy
