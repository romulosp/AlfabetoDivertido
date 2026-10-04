extends SceneTree

const CATALOG: ContentCatalog = preload("res://data/content_catalog.tres")
const NARRATION: NarrationCatalog = preload("res://data/narration_catalog.tres")

var _checks: int = 0
var _failures: PackedStringArray = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	for card: WordCard in CATALOG.rounds:
		for phrase: String in ["Qual é a primeira letra de %s?" % card.word, "Monte a palavra %s." % card.word, "%s. %s! Muito bem!" % [card.word[0], card.word], "%s! Muito bem!" % card.word]:
			_check(NARRATION.clips.has(phrase), "narração de " + phrase)
	for card: WordCard in CATALOG.examples:
		_check(NARRATION.clips.has(card.letter), "narração da letra " + card.letter)
		_check(NARRATION.clips.has("%s de %s" % [card.letter, card.word]), "narração do exemplo " + card.letter)
	for phrase: String in ["Toque em uma letra para ouvir.", "Tente outra letra.", "Quase! Tente de novo.", "Uau! Que incrível!", "Muito bem! Parabéns!"]:
		_check(NARRATION.clips.has(phrase), "narração do feedback " + phrase)
	for clip: AudioStream in NARRATION.clips.values():
		_check(clip.get_length() > 0.1, "áudio possui duração real")
	var audio: GameAudio = GameAudio.new()
	root.add_child(audio)
	audio.speak("A", "A de ABELHA")
	_check(audio._narrator.playing, "narração inicia")
	_check(audio._narrator.stream == NARRATION.clips["A"], "pronuncia letra primeiro")
	audio._narrator.finished.emit()
	_check(audio._narrator.stream == NARRATION.clips["A de ABELHA"], "exemplo após fim da letra")
	audio.speak("B", "B de BOLA")
	audio.speak("Z", "Z de ZEBRA")
	_check(audio._next_text == "Z de ZEBRA", "seleção rápida substitui fila")
	audio.play_effect("tap")
	audio.set_enabled(false)
	_check(not audio._narrator.playing and not audio._player.playing, "mute interrompe voz e efeitos")
	_check(audio._next_text.is_empty(), "mute limpa continuação")
	audio.set_enabled(true)
	_check(not audio._narrator.playing, "religar não retoma áudio antigo")
	audio.speak("A", "A de ABELHA")
	audio.stop()
	audio._narrator.finished.emit()
	_check(not audio._narrator.playing, "saída invalida continuação")
	audio.free()
	print(JSON.stringify({"suite": "godot_audio", "checks": _checks, "failures": _failures}))
	quit(0 if _failures.is_empty() else 1)


func _check(condition: bool, description: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(description)
		push_error(description)
