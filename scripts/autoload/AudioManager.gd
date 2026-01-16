# res://autoload/AudioManager.gd
extends Node

# Audio Players
var music_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer
var ui_player: AudioStreamPlayer
var ambient_player: AudioStreamPlayer

# Sound Library Paths (Lazy Loading)
const SFX_LIBRARY = {
	# UI
	"phone_ring_loop": "res://assets/audio/sfx/ui/phone_ring_loop.ogg",
	"phone_pickup": "res://assets/audio/sfx/ui/phone_pickup.ogg",
	"phone_hangup": "res://assets/audio/sfx/ui/phone_hangup.ogg",
	"ui_error": "res://assets/audio/sfx/ui/ui_error.ogg",
	"ui_success": "res://assets/audio/sfx/ui/ui_success_chime.ogg",
	"typewriter": "res://assets/audio/sfx/ui/typewriter_blip.ogg",
	
	# Movement
	"step_concrete_sneak": "res://assets/audio/sfx/movement/footstep_concrete_sneak.ogg",
	"step_concrete_run": "res://assets/audio/sfx/movement/footstep_concrete_run.ogg",
	"step_wood_walk": "res://assets/audio/sfx/movement/footstep_interior_wood.ogg",
	"gear_rustle": "res://assets/audio/sfx/movement/gear_rustle_loop.ogg",
	
	# Tools
	"lockpick_fumble": "res://assets/audio/sfx/tools/lockpick_fumble.ogg",
	"lockpick_success": "res://assets/audio/sfx/tools/lockpick_success.ogg",
	"drill_loop": "res://assets/audio/sfx/tools/drill_loop.ogg",
	"hacking_typing": "res://assets/audio/sfx/tools/hacking_typing.ogg",
	"hacking_success": "res://assets/audio/sfx/tools/hacking_access_granted.ogg",
	
	# Ambience
	"amb_city_night": "res://assets/audio/ambience/ambience_city_night.ogg",
	"amb_pub": "res://assets/audio/ambience/ambience_pub_interior.ogg",
	"amb_rain": "res://assets/audio/ambience/ambience_rain_loop.ogg",
	"amb_blueprint": "res://assets/audio/ambience/ambience_blueprint_hum.ogg",
	
	# Narrative / Loop
	"loop_siren": "res://assets/audio/sfx/narrative/loop_reset_siren.ogg",
	"glitch_burst": "res://assets/audio/sfx/narrative/digital_glitch_burst.ogg"
}

# Cache for loaded resources
var _loaded_sounds = {}

func _ready() -> void:
	# Setup Buses
	music_player = _create_player("Music")
	sfx_player = _create_player("Gameplay")
	ui_player = _create_player("UI")
	ambient_player = _create_player("Ambience")

func _create_player(bus_name: String) -> AudioStreamPlayer:
	var p = AudioStreamPlayer.new()
	p.bus = bus_name
	add_child(p)
	return p

func _get_sound(key: String) -> AudioStream:
	if key in _loaded_sounds:
		return _loaded_sounds[key]
	
	if key in SFX_LIBRARY:
		var path = SFX_LIBRARY[key]
		if ResourceLoader.exists(path):
			var s = load(path)
			# Nastavit loop pro smyčky
			if "loop" in key or "amb_" in key:
				if s is AudioStreamOggVorbis:
					s.loop = true
			_loaded_sounds[key] = s
			return s
		else:
			push_warning("Audio file not found: " + path)
	else:
		push_warning("Audio key not found in library: " + key)
	return null

# --- Public API ---

func play_music(stream: AudioStream, volume_db: float = -6.0) -> void:
	if not stream: return
	music_player.stream = stream
	music_player.volume_db = volume_db
	music_player.play()

func play_sfx_stream(stream: AudioStream, volume_db: float = -3.0, pitch: float = 1.0) -> void:
	# Legacy direct stream method
	if not stream: return
	sfx_player.stream = stream
	sfx_player.pitch_scale = pitch
	sfx_player.volume_db = volume_db
	sfx_player.play()

# UI Sounds
func play_ui_sound(key: String, volume_db: float = -5.0, pitch: float = 1.0) -> void:
	var stream = _get_sound(key)
	if stream:
		ui_player.stream = stream
		ui_player.volume_db = volume_db
		ui_player.pitch_scale = pitch
		ui_player.play()

func play_dialogue_blip(pitch: float = 1.0):
	play_ui_sound("typewriter", -12.0, pitch + randf_range(-0.1, 0.1))

func start_phone_ring():
	var stream = _get_sound("phone_ring_loop")
	if stream:
		ui_player.stream = stream
		ui_player.volume_db = -5.0
		ui_player.play()

func stop_phone_ring():
	if ui_player.playing and ui_player.stream == _get_sound("phone_ring_loop"):
		ui_player.stop()

# Movement Sounds
func play_footstep(surface: String = "concrete", style: String = "sneak"):
	var key = "step_concrete_sneak" # Default
	
	if style == "run":
		key = "step_concrete_run"
	elif surface == "wood":
		key = "step_wood_walk"
	
	# Randomize pitch slightly for variation
	var pitch = randf_range(0.95, 1.05)
	
	# Use SFX player (or we could use a dedicated polyphonic player for overlapping steps)
	var stream = _get_sound(key)
	if stream:
		sfx_player.stream = stream
		sfx_player.pitch_scale = pitch
		sfx_player.volume_db = -6.0 if style == "sneak" else -2.0
		sfx_player.play()

# Tool Sounds
func play_tool_sfx(key: String):
	var stream = _get_sound(key)
	if stream:
		sfx_player.stream = stream
		sfx_player.volume_db = -4.0
		sfx_player.play()

# Ambience
func start_ambient(key: String, fade_time: float = 1.0):
	var stream = _get_sound(key)
	if not stream: return
	
	if ambient_player.playing and ambient_player.stream == stream:
		return # Already playing this ambience
	
	# Simple fade out/in logic could go here, for now direct switch
	ambient_player.stream = stream
	ambient_player.volume_db = -10.0 # Start quieter
	ambient_player.play()
	
	# Tween volume up
	var tween = create_tween()
	tween.tween_property(ambient_player, "volume_db", -6.0, fade_time)

func stop_ambient(fade_time: float = 1.0):
	var tween = create_tween()
	tween.tween_property(ambient_player, "volume_db", -80.0, fade_time)
	tween.tween_callback(ambient_player.stop)
