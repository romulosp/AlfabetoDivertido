class_name GameAudio
extends Node

## Bundled pt-BR recordings never depend on an Android voice or internet access.

const NARRATION: NarrationCatalog = preload("res://data/narration_catalog.tres")

var enabled: bool = true
var _next_text: String = ""
var _player: AudioStreamPlayer
var _narrator: AudioStreamPlayer
var _sounds: Dictionary[String, AudioStreamWAV] = {}


func _ready() -> void:
	_player = AudioStreamPlayer.new()
	_player.volume_db = -16.0
	add_child(_player)
	_narrator = AudioStreamPlayer.new()
	_narrator.finished.connect(_on_narration_finished)
	add_child(_narrator)
	_sounds["correct"] = _make_tone(660.0, 0.18)
	_sounds["wrong"] = _make_tone(220.0, 0.12)
	_sounds["tap"] = _make_tone(520.0, 0.08)


func _exit_tree() -> void:
	stop()


func set_enabled(value: bool) -> void:
	enabled = value
	if not enabled:
		stop()


func stop() -> void:
	_next_text = ""
	if is_instance_valid(_player):
		_player.stop()
	if is_instance_valid(_narrator):
		_narrator.stop()


func speak(text: String, following: String = "") -> void:
	stop()
	if not enabled or not NARRATION.clips.has(text):
		return
	_next_text = following
	_narrator.stream = NARRATION.clips[text]
	_narrator.play()


func play_effect(kind: String) -> void:
	if enabled and _sounds.has(kind):
		_player.stream = _sounds[kind]
		_player.play()


func _on_narration_finished() -> void:
	if not enabled or _next_text.is_empty():
		return
	var text: String = _next_text
	_next_text = ""
	if NARRATION.clips.has(text):
		_narrator.stream = NARRATION.clips[text]
		_narrator.play()


func _make_tone(frequency: float, duration: float) -> AudioStreamWAV:
	var sample_rate: int = 22_050
	var count: int = int(float(sample_rate) * duration)
	var data: PackedByteArray = PackedByteArray()
	data.resize(count * 2)
	for index: int in range(count):
		var envelope: float = sin(PI * float(index) / float(count))
		var value: float = sin(TAU * frequency * float(index) / float(sample_rate))
		data.encode_s16(index * 2, int(value * envelope * 12_000.0))
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.data = data
	return stream
