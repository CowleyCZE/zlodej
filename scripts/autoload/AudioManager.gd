# res://autoload/AudioManager.gd
extends Node

var music_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer
var ui_player: AudioStreamPlayer

@export var dialogue_blip_sound: AudioStream # Assigned in editor
@export var phone_ring_sound: AudioStream # Assigned in editor

func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	sfx_player = AudioStreamPlayer.new()
	sfx_player.bus = "Gameplay"
	ui_player = AudioStreamPlayer.new()
	ui_player.bus = "UI"
	
	add_child(music_player)
	add_child(sfx_player)
	add_child(ui_player)

func play_music(stream: AudioStream, volume_db: float = -6.0) -> void:
	if not stream: return
	music_player.stream = stream
	music_player.volume_db = volume_db
	music_player.play()

func play_sfx(stream: AudioStream, volume_db: float = -3.0, pitch: float = 1.0) -> void:
	if not stream: return
	sfx_player.stream = stream
	sfx_player.pitch_scale = pitch
	sfx_player.volume_db = volume_db
	sfx_player.play()

func play_ui(stream: AudioStream, volume_db: float = -5.0, pitch: float = 1.0) -> void:
	if not stream: return
	ui_player.stream = stream
	ui_player.pitch_scale = pitch
	ui_player.volume_db = volume_db
	ui_player.play()

func play_dialogue_blip(pitch: float = 1.0):
	if dialogue_blip_sound:
		play_ui(dialogue_blip_sound, -12.0, pitch + randf_range(-0.1, 0.1))

func play_phone_ring():
	if phone_ring_sound:
		play_ui(phone_ring_sound, -5.0)
	else:
		print("AUDIO: Phone ring placeholder sound!")
