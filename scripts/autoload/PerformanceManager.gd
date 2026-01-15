# res://autoload/PerformanceManager.gd
extends Node

enum Mode { HIGH, BALANCED, BATTERY_SAVER }

func set_mode(mode: Mode) -> void:
	match mode:
		Mode.HIGH:
			ProjectSettings.set_setting("rendering/quality/shadows/soft_shadows", true)
			Engine.max_fps = 60
		Mode.BALANCED:
			ProjectSettings.set_setting("rendering/quality/shadows/soft_shadows", false)
			Engine.max_fps = 30
		Mode.BATTERY_SAVER:
			ProjectSettings.set_setting("rendering/quality/filters/use_nearest_mipmap_filter", true)
			Engine.max_fps = 20
