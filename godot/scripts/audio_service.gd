extends Node

var current_id: String = ""
var current_text: String = ""
var voice: AudioStreamPlayer
var effects: AudioStreamPlayer
var lines: Dictionary = {}
var volumes: Dictionary = {"voice":0.8,"effects":0.6,"music":0.3,"ui":0.6}

func _ready() -> void:
	for bus_name: String in ["Voice","Effects","Music","UI"]:
		if AudioServer.get_bus_index(bus_name) == -1:
			AudioServer.add_bus()
			AudioServer.set_bus_name(AudioServer.bus_count - 1, bus_name)
	voice = AudioStreamPlayer.new()
	voice.bus = "Voice"
	add_child(voice)
	voice.finished.connect(_finished)
	effects = AudioStreamPlayer.new()
	effects.bus = "Effects"
	add_child(effects)
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://content/speech.json"))
	if parsed is Dictionary:
		lines = parsed
	volumes = ProgressService.store.data.audioSettings.duplicate()
	for channel: String in volumes:
		set_volume(channel, float(volumes[channel]))

func speak(speech_id: String) -> void:
	stop()
	if not lines.has(speech_id):
		return
	current_id = speech_id
	current_text = lines[speech_id].text
	EventBus.speech_changed.emit(current_text)
	var file: String = lines[speech_id].file
	if ResourceLoader.exists(file):
		voice.stream = load(file) as AudioStream
		voice.play()
	else:
		push_warning("Áudio ausente: " + speech_id)

func repeat() -> void:
	var previous: String = current_id
	speak(previous)

func _finished() -> void:
	EventBus.speech_finished.emit()

func stop() -> void:
	if is_instance_valid(voice):
		voice.stop()
	current_id = ""
	EventBus.speech_finished.emit()

func is_speaking() -> bool:
	return is_instance_valid(voice) and voice.playing

func set_volume(channel: String, value: float) -> void:
	if not channel in volumes:
		return
	volumes[channel] = clampf(value, 0.0, 1.0)
	var bus_index: int = AudioServer.get_bus_index(channel.capitalize())
	if bus_index >= 0:
		AudioServer.set_bus_volume_linear(bus_index, float(volumes[channel]))

func play_effect(correct: bool) -> void:
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = 22050
	var samples: PackedByteArray = PackedByteArray()
	samples.resize(6615 * 2)
	for index: int in range(6615):
		var t: float = float(index) / 22050.0
		var sample: int = int(sin(t * TAU * (660.0 if correct else 330.0)) * 7000.0 * (1.0 - float(index) / 6615.0))
		samples.encode_s16(index * 2, sample)
	stream.data = samples
	effects.stream = stream
	effects.play()
