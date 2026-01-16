class_name WeatherController
extends CanvasLayer

# Visual Elements
var rain_particles: GPUParticles2D
var fog_particles: GPUParticles2D
var mood_overlay: ColorRect
var tween: Tween

func _ready() -> void:
	layer = 5 # Overlay layer (above game, below HUD which is usually 10+)
	
	_setup_overlay()
	_setup_rain()
	_setup_fog()
	
	# Initial Sync
	call_deferred("_update_visuals")
	
	# Connections
	WeatherManager.weather_changed.connect(func(_w): _update_visuals())
	TimeManager.time_changed.connect(func(_t): _update_visuals())
	if PerformanceManager.has_signal("quality_changed"):
		PerformanceManager.quality_changed.connect(func(_q): _on_quality_changed())

func _on_quality_changed():
	# Re-initialize particles with new amounts
	if rain_particles: rain_particles.queue_free()
	if fog_particles: fog_particles.queue_free()
	_setup_rain()
	_setup_fog()
	_update_visuals()

func _setup_overlay() -> void:
	mood_overlay = ColorRect.new()
	mood_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	mood_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mood_overlay.color = Color(0, 0, 0, 0) # Start transparent
	add_child(mood_overlay)

func _setup_rain() -> void:
	rain_particles = GPUParticles2D.new()
	rain_particles.name = "Rain"
	add_child(rain_particles)
	
	var mult = PerformanceManager.get_max_particles_mult()
	rain_particles.amount = int(1500 * mult) if mult > 0.01 else 1 
	rain_particles.emitting = false # Keep logical emitting separate
	rain_particles.lifetime = 1.0
	rain_particles.preprocess = 1.0
	rain_particles.visibility_rect = Rect2(0, 0, 2000, 2000)
	rain_particles.emitting = false
	
	var mat = ParticleProcessMaterial.new()
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	mat.emission_box_extents = Vector3(1000, 10, 1) # Width of screen
	mat.direction = Vector3(-0.2, 1, 0) # Slight diagonal
	mat.spread = 2.0
	mat.gravity = Vector3(0, 0, 0)
	mat.initial_velocity_min = 1000.0
	mat.initial_velocity_max = 1500.0
	mat.color = Color(0.8, 0.85, 1.0, 0.5)
	
	# Rain needs to look like lines
	rain_particles.trail_enabled = true
	rain_particles.trail_lifetime = 0.05
	
	rain_particles.process_material = mat
	
	# Position top-center (relative to screen)
	rain_particles.position = Vector2(960, -50)

func _setup_fog() -> void:
	fog_particles = GPUParticles2D.new()
	fog_particles.name = "Fog"
	add_child(fog_particles)
	
	var mult = PerformanceManager.get_max_particles_mult()
	fog_particles.amount = int(60 * mult) if mult > 0.01 else 1
	fog_particles.lifetime = 8.0
	fog_particles.preprocess = 8.0
	fog_particles.emitting = false
	
	# Create a soft blob texture programmatically
	var grad = Gradient.new()
	grad.set_color(0, Color(1, 1, 1, 0.3))
	grad.set_color(1, Color(1, 1, 1, 0.0))
	
	var tex = GradientTexture2D.new()
	tex.gradient = grad
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	tex.width = 64
	tex.height = 64
	
	fog_particles.texture = tex
	
	var mat = ParticleProcessMaterial.new()
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	mat.emission_box_extents = Vector3(1000, 600, 1)
	mat.gravity = Vector3(20, 0, 0) # Wind
	mat.scale_min = 4.0
	mat.scale_max = 8.0
	mat.color = Color(1, 1, 1, 0.15)
	mat.turbulence_enabled = true
	mat.turbulence_noise_strength = 2.0
	
	fog_particles.process_material = mat
	fog_particles.position = Vector2(960, 540)

func _update_visuals() -> void:
	var weather = WeatherManager.current_weather
	var time = TimeManager.current_slot
	
	if tween: tween.kill()
	tween = create_tween().set_parallel(true)
	
	# 1. Particles
	var rain_active = (weather == WeatherManager.WeatherType.RAIN)
	var fog_active = (weather == WeatherManager.WeatherType.FOG)
	
	rain_particles.emitting = rain_active
	fog_particles.emitting = fog_active
	
	# 2. Mood Overlay Color
	var target_color = Color(0, 0, 0, 0) # Clear
	
	if time == TimeManager.TimeSlot.NIGHT:
		target_color = Color(0.05, 0.05, 0.2, 0.5) # Dark Blue Night
	elif time == TimeManager.TimeSlot.EVENING:
		target_color = Color(0.2, 0.1, 0.05, 0.2) # Orange tint
	
	# Weather modifier
	if weather == WeatherManager.WeatherType.RAIN:
		# Rain makes it darker and bluer
		target_color = target_color.lerp(Color(0.1, 0.15, 0.3, 0.5), 0.5)
	elif weather == WeatherManager.WeatherType.FOG:
		# Fog makes it grey/white and hazy
		target_color = target_color.lerp(Color(0.8, 0.8, 0.8, 0.2), 0.3)
		
	tween.tween_property(mood_overlay, "color", target_color, 2.0)