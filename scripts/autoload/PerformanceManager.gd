# PerformanceManager.gd (Autoload)
extends Node

enum Quality { LOW, MEDIUM, HIGH }

var current_quality: Quality = Quality.HIGH:
	set(value):
		if current_quality != value:
			current_quality = value
			_apply_quality()
			quality_changed.emit(current_quality)

signal quality_changed(new_quality: Quality)

func _ready():
	# Default to balanced for Android, High for PC
	if OS.has_feature("mobile"):
		current_quality = Quality.MEDIUM
	else:
		current_quality = Quality.HIGH
	_apply_quality()

func _apply_quality():
	match current_quality:
		Quality.LOW:
			Engine.max_fps = 30
			RenderingServer.viewport_set_msaa_2d(get_viewport().get_viewport_rid(), RenderingServer.VIEWPORT_MSAA_DISABLED)
			print("PERF: Quality set to LOW (Battery Saver)")
		Quality.MEDIUM:
			Engine.max_fps = 60
			RenderingServer.viewport_set_msaa_2d(get_viewport().get_viewport_rid(), RenderingServer.VIEWPORT_MSAA_2X)
			print("PERF: Quality set to MEDIUM (Balanced)")
		Quality.HIGH:
			Engine.max_fps = 0 # Uncapped (V-Sync handles)
			RenderingServer.viewport_set_msaa_2d(get_viewport().get_viewport_rid(), RenderingServer.VIEWPORT_MSAA_4X)
			print("PERF: Quality set to HIGH")

func get_max_particles_mult() -> float:
	match current_quality:
		Quality.LOW: return 0.0
		Quality.MEDIUM: return 0.4
		Quality.HIGH: return 1.0
	return 1.0

func use_complex_shaders() -> bool:
	return current_quality != Quality.LOW