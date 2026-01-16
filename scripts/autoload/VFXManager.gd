# VFXManager.gd (Autoload)
extends CanvasLayer

var glitch_rect: ColorRect
var glitch_material: ShaderMaterial

func _ready():
	layer = 100 # High layer to be above everything
	
	# Setup Glitch Overlay
	glitch_rect = ColorRect.new()
	glitch_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	glitch_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	glitch_material = ShaderMaterial.new()
	glitch_material.shader = load("res://assets/materials/screen_glitch.gdshader")
	glitch_material.set_shader_parameter("intensity", 0.0)
	
	glitch_rect.material = glitch_material
	add_child(glitch_rect)
	
	print("VFXManager: Initialized.")

func trigger_glitch(duration: float = 1.0, intensity: float = 0.5):
	var tween = create_tween()
	# Burst in
	tween.tween_method(func(v): glitch_material.set_shader_parameter("intensity", v), 0.0, intensity, duration * 0.2)
	# Fade out
	tween.tween_method(func(v): glitch_material.set_shader_parameter("intensity", v), intensity, 0.0, duration * 0.8)
