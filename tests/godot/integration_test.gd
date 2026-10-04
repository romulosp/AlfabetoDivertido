extends SceneTree

const MainScene: PackedScene = preload("res://scenes/main.tscn")
const Session = preload("res://scripts/game_session.gd")

var _checks: int = 0
var _failures: PackedStringArray = []
var _app: Control


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_app = MainScene.instantiate()
	root.add_child(_app)
	await process_frame
	_app.audio.set_enabled(false)
	_check(_app.screen == _app.Screen.MENU, "inicia no menu")
	_check(_app.find_child("AuthorCredit", true, false) != null, "crédito do autor na primeira tela")
	_check(_app.find_child("MascotName", true, false) == null, "mascote escondido no menu")
	_check(_app.get_tree().get_nodes_in_group("mode_button").size() == 3, "três modos no menu")
	for mode: int in [Session.Mode.INITIAL, Session.Mode.WORD]:
		_app.start_mode(mode)
		await process_frame
		_check(_app.find_child("AuthorCredit", true, false) == null, "atividade sem crédito do autor")
		var mascot_name: Label = _app.find_child("MascotName", true, false) as Label
		_check(mascot_name != null and mascot_name.text == "Rômulo Penha", "nome do mascote visível no jogo")
		var mascot: MascotAnimation = _app.find_child("MascotAnimation", true, false) as MascotAnimation
		_check(mascot != null and mascot.FRAMES.get_frame_count(&"idle") == 16, "espera renderizada em Blender")
		mascot.play(&"confused")
		mascot._process(1.0)
		_check(mascot.animation == &"idle", "reação retorna à espera")
		mascot.motion_enabled = false
		mascot._process(0.5)
		_check(mascot.texture == mascot.FRAMES.get_frame_texture(&"idle", 0), "movimento reduzido mantém pose estática")
		for index: int in range(8):
			var word: String = _app.session.current_card().word
			if mode == Session.Mode.INITIAL:
				_app.choose_initial(word[0])
				await process_frame
			else:
				for letter: String in word:
					for occurrence: int in range(_app.session.occurrences.size()):
						if _app.session.occurrences[occurrence] == letter and not _app.session.used[occurrence]:
							_app.choose_occurrence(occurrence)
							await process_frame
							break
			_check(_app.advance_timer.time_left > 0.0, "avanço agendado")
			_app.advance_timer.stop()
			_app.advance_timer.timeout.emit()
			await process_frame
		_check(_app.screen == _app.Screen.CELEBRATION, "rodada chega à celebração")
		_check(_app.find_child("AuthorCredit", true, false) == null, "celebração sem crédito do autor")
		_check(_app.session.first_attempts == 8, "oito acertos de primeira")
		_app.start_mode(mode)
		await process_frame
		_check(_app.session.results.is_empty(), "jogar novamente zera rodada")
		_app.back_to_menu()
	_app.start_mode(Session.Mode.INITIAL)
	_app.choose_initial(_app.session.current_card().word[0])
	_app.back_to_menu()
	_check(_app.advance_timer.is_stopped(), "saída cancela avanço")
	_app.start_mode(Session.Mode.ALPHABET)
	for index: int in range(26):
		_app.select_letter(index)
		await process_frame
		_check(_app.selected_letter == index, "última letra selecionada")
	_check(_app.session.results.is_empty(), "alfabeto sem pontuação")
	_app.back_to_menu()
	var cancel: InputEventKey = InputEventKey.new()
	cancel.keycode = KEY_ESCAPE
	cancel.pressed = true
	_app.start_mode(Session.Mode.WORD)
	_app._unhandled_key_input(cancel)
	_check(_app.screen == _app.Screen.MENU, "Escape volta ao menu")
	_check(not _app.audio.enabled, "som persiste desligado entre telas")
	_check(ProjectSettings.get_setting("display/window/size/mode") == Window.MODE_FULLSCREEN, "abre em tela cheia")
	_check(ProjectSettings.get_setting("display/window/handheld/orientation") == DisplayServer.SCREEN_LANDSCAPE, "orientação paisagem")
	_check(not quit_on_go_back, "botão Voltar do Android não encerra a atividade")
	_app.start_mode(Session.Mode.INITIAL)
	_app._notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	_check(_app.screen == _app.Screen.MENU, "Voltar do Android retorna ao menu")
	print(JSON.stringify({"suite": "godot_integration", "checks": _checks, "failures": _failures}))
	_app._stop_tweens()
	_app.free()
	await process_frame
	await process_frame
	quit.call_deferred(0 if _failures.is_empty() else 1)


func _check(condition: bool, description: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(description)
		push_error(description)
