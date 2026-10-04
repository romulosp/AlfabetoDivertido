class_name AlfabetoApp
extends Control

## A single controller coordinates rules, audio and the current touch interface.

enum Screen {
	MENU,
	GAME,
	CELEBRATION,
}

const CATALOG: ContentCatalog = preload("res://data/content_catalog.tres")
const FONT: Font = preload("res://assets/fonts/nunito.ttf")
const HOME: Texture2D = preload("res://assets/home.svg")
const SOUND_ON: Texture2D = preload("res://assets/sound_on.svg")
const SOUND_OFF: Texture2D = preload("res://assets/sound_off.svg")
const BACKGROUND: Texture2D = preload("res://assets/background.svg")
const MODE_NAMES: PackedStringArray = ["Primeira Letra", "Monte a Palavra", "Brincar com o Alfabeto"]
const MODE_HINTS: PackedStringArray = ["Qual letra começa a palavra?", "Coloque as letras na ordem", "Toque em cada letra e ouça"]

var screen: int = Screen.MENU
var session: GameSession = GameSession.new(CATALOG)
var audio: GameAudio
var advance_timer: Timer
var selected_letter: int = -1
var _frame: VBoxContainer
var _view: MarginContainer
var _feedback: Label
var _bubble: Label
var _mascot_image: MascotAnimation
var _mascot_reaction: StringName = &"idle"
var _feedback_text: String = ""
var _feedback_color: Color = UiStyles.INK
var _mascot_text: String = ""
var _bubble_timer: Timer
var _responses: Array[Button] = []
var _slots: Array[Label] = []
var _tweens: Array[Tween] = []
var _motion_enabled: bool = true
var _render_pending: bool = false
var _landscape: bool = false
var _compact: bool = false


func _ready() -> void:
	var app_theme: Theme = Theme.new()
	var app_font: FontVariation = FontVariation.new()
	app_font.base_font = FONT
	app_font.variation_opentype = {&"wght": 750.0}
	app_font.variation_embolden = 0.6
	app_theme.default_font = app_font
	app_theme.default_font_size = 18
	theme = app_theme
	var background: TextureRect = UiStyles.image(BACKGROUND, Vector2.ZERO)
	background.stretch_mode = TextureRect.STRETCH_SCALE
	add_child(background)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	get_tree().auto_accept_quit = false
	get_tree().quit_on_go_back = false
	audio = GameAudio.new()
	audio.name = "Audio"
	add_child(audio)
	advance_timer = Timer.new()
	advance_timer.name = "AdvanceTimer"
	advance_timer.one_shot = true
	advance_timer.timeout.connect(_on_advance_timeout)
	add_child(advance_timer)
	_bubble_timer = Timer.new()
	_bubble_timer.one_shot = true
	_bubble_timer.timeout.connect(_on_bubble_timeout)
	add_child(_bubble_timer)
	if DisplayServer.get_name() != "headless":
		_motion_enabled = DisplayServer.accessibility_should_reduce_animation() != 1
	resized.connect(_queue_render)
	_render()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST or what == NOTIFICATION_WM_CLOSE_REQUEST:
		if screen != Screen.MENU:
			back_to_menu()
		else:
			get_tree().quit()
	elif what == NOTIFICATION_APPLICATION_PAUSED and is_instance_valid(audio):
		audio.stop()


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and screen != Screen.MENU:
		back_to_menu()
		get_viewport().set_input_as_handled()


func start_mode(mode: int) -> void:
	_cancel_activity()
	session.start(mode)
	selected_letter = -1
	_feedback_text = ""
	_feedback_color = UiStyles.INK
	screen = Screen.GAME
	_mascot_text = "Toca numa letra!" if mode == GameSession.Mode.ALPHABET else "Vamos brincar!"
	_bubble_timer.start(2.2)
	_render()
	_narrate_question()


func back_to_menu() -> void:
	_cancel_activity()
	screen = Screen.MENU
	_feedback_text = ""
	selected_letter = -1
	_render()


func choose_initial(letter: String) -> void:
	if screen != Screen.GAME:
		return
	var result: int = session.choose_initial(letter)
	if result == GameSession.Answer.WRONG:
		_wrong_answer("Quase! Tente outra letra", "Tenta outra!")
	elif result == GameSession.Answer.COMPLETE:
		var word: String = session.current_card().word
		_feedback_text = "%s de %s!" % [letter, word]
		_finish_question("%s. %s! Muito bem!" % [letter, word], "Isso!", 1.6)


func choose_occurrence(occurrence: int) -> void:
	if screen != Screen.GAME:
		return
	var result: int = session.choose_occurrence(occurrence)
	if result == GameSession.Answer.WRONG:
		_wrong_answer("A próxima letra é outra. Tente de novo", "Tenta de novo!")
	elif result == GameSession.Answer.PLACED:
		_mascot_reaction = &"happy"
		_feedback_text = "Muito bem! Continue montando!"
		_feedback_color = Color("285723")
		_mascot_text = "Continua!"
		_bubble_timer.start(2.2)
		audio.play_effect("tap")
		_render()
	elif result == GameSession.Answer.COMPLETE:
		var word: String = session.current_card().word
		_feedback_text = "Isso! %s!" % word
		_finish_question("%s! Muito bem!" % word, "Montou tudinho!", 1.8)


func select_letter(index: int) -> void:
	if screen != Screen.GAME or session.mode != GameSession.Mode.ALPHABET:
		return
	if index < 0 or index >= CATALOG.examples.size():
		return
	selected_letter = index
	_mascot_reaction = &"happy"
	var card: WordCard = CATALOG.examples[index]
	_feedback_text = "%s de %s" % [card.letter, card.word]
	_feedback_color = UiStyles.INK
	_mascot_text = _feedback_text
	_bubble_timer.start(2.2)
	_render()
	audio.speak(card.letter, _feedback_text)
	audio.play_effect("tap")
	_pop(_responses[index])


func _cancel_activity() -> void:
	advance_timer.stop()
	_bubble_timer.stop()
	_mascot_text = ""
	_mascot_reaction = &"idle"
	audio.stop()
	_stop_tweens()


func _wrong_answer(text: String, encouragement: String) -> void:
	_mascot_reaction = &"confused"
	_feedback_text = text
	_feedback_color = Color("942435")
	_mascot_text = encouragement
	_bubble_timer.start(2.2)
	audio.speak("Tente outra letra." if session.mode == GameSession.Mode.WORD else "Quase! Tente de novo.")
	audio.play_effect("wrong")
	_render()


func _finish_question(spoken: String, encouragement: String, delay: float) -> void:
	_mascot_reaction = &"happy"
	_feedback_color = Color("285723")
	_mascot_text = encouragement
	_bubble_timer.start(2.2)
	audio.speak(spoken)
	audio.play_effect("correct")
	_render()
	advance_timer.start(delay)


func _on_advance_timeout() -> void:
	if screen != Screen.GAME or not session.is_complete:
		return
	audio.stop()
	_feedback_text = ""
	_feedback_color = UiStyles.INK
	if session.advance():
		_mascot_reaction = &"idle"
		_render()
		_narrate_question()
	else:
		_cancel_activity()
		screen = Screen.CELEBRATION
		_mascot_reaction = &"happy"
		_mascot_text = "Você é fera!" if session.first_attempts == 8 else "Mandou bem!"
		_bubble_timer.start(2.2)
		_render()
		audio.speak("Uau! Que incrível!" if session.first_attempts == 8 else "Muito bem! Parabéns!")
		audio.play_effect("correct")


func _on_bubble_timeout() -> void:
	_mascot_text = ""
	if is_instance_valid(_bubble):
		_bubble.text = ""


func _narrate_question() -> void:
	if session.mode == GameSession.Mode.ALPHABET:
		audio.speak("Toque em uma letra para ouvir.")
	else:
		var word: String = session.current_card().word
		audio.speak("Monte a palavra %s." % word if session.mode == GameSession.Mode.WORD else "Qual é a primeira letra de %s?" % word)


func _queue_render() -> void:
	if not _render_pending:
		_render_pending = true
		_render.call_deferred()


func _render() -> void:
	_render_pending = false
	_stop_tweens()
	_responses.clear()
	_slots.clear()
	if is_instance_valid(_view):
		remove_child(_view)
		_view.queue_free()
	_landscape = size.x > size.y * 1.12
	_compact = size.y < 600.0
	_view = MarginContainer.new()
	_view.name = "SafeArea"
	add_child(_view)
	_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var margin: int = 6 if _compact and _landscape else 10 if _compact else 16
	for side: String in ["left", "top", "right", "bottom"]:
		_view.add_theme_constant_override("margin_" + side, margin)
	_apply_safe_area(margin)
	_frame = VBoxContainer.new()
	_frame.name = "Frame"
	_frame.add_theme_constant_override("separation", 4 if _compact and _landscape else 8 if _compact else 12)
	_view.add_child(_frame)
	_build_header()
	var stage: VBoxContainer = VBoxContainer.new()
	stage.name = "Stage"
	stage.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stage.alignment = BoxContainer.ALIGNMENT_CENTER
	stage.add_theme_constant_override("separation", 8)
	_frame.add_child(stage)
	match screen:
		Screen.MENU:
			_build_menu(stage)
		Screen.GAME:
			_build_game(stage)
		Screen.CELEBRATION:
			_build_celebration(stage)
	_build_footer()
	_focus_default.call_deferred()


func _apply_safe_area(margin: int) -> void:
	if OS.get_name() != "Android":
		return
	var safe: Rect2i = DisplayServer.get_display_safe_area()
	var physical: Vector2i = DisplayServer.window_get_size()
	if physical.x <= 0 or physical.y <= 0:
		return
	var scale_factor: Vector2 = size / Vector2(physical)
	_view.add_theme_constant_override("margin_left", maxi(margin, int(float(safe.position.x) * scale_factor.x)))
	_view.add_theme_constant_override("margin_top", maxi(margin, int(float(safe.position.y) * scale_factor.y)))
	_view.add_theme_constant_override("margin_right", maxi(margin, int(float(physical.x - safe.end.x) * scale_factor.x)))
	_view.add_theme_constant_override("margin_bottom", maxi(margin, int(float(physical.y - safe.end.y) * scale_factor.y)))


func _build_header() -> void:
	var header: HBoxContainer = HBoxContainer.new()
	header.name = "Header"
	header.add_theme_constant_override("separation", 8)
	_frame.add_child(header)
	if screen != Screen.MENU:
		var home: Button = _icon_button(HOME, "Voltar ao menu")
		home.pressed.connect(back_to_menu)
		header.add_child(home)
	else:
		var motion: Button = UiStyles.button("↝", Color.WHITE, 24)
		motion.name = "MotionToggle"
		motion.tooltip_text = "Reduzir movimentos" if _motion_enabled else "Ativar movimentos"
		motion.toggle_mode = true
		motion.button_pressed = not _motion_enabled
		motion.pressed.connect(_toggle_motion)
		header.add_child(motion)
	var middle: VBoxContainer = VBoxContainer.new()
	middle.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	middle.alignment = BoxContainer.ALIGNMENT_CENTER
	middle.add_theme_constant_override("separation", 3)
	header.add_child(middle)
	if screen == Screen.GAME:
		middle.add_child(UiStyles.label(MODE_NAMES[session.mode], 12))
		if session.mode != GameSession.Mode.ALPHABET:
			var dots: HBoxContainer = HBoxContainer.new()
			dots.alignment = BoxContainer.ALIGNMENT_CENTER
			dots.add_theme_constant_override("separation", 5)
			middle.add_child(dots)
			for index: int in range(GameSession.ROUND_SIZE):
				var dot: Label = UiStyles.label(str(index + 1), 10)
				var color: Color = Color.WHITE
				if index < session.results.size():
					color = UiStyles.GREEN if session.results[index] else UiStyles.ORANGE
					dot.text = "✓" if session.results[index] else "↻"
				dot.custom_minimum_size = Vector2(18, 18)
				var dot_style: StyleBoxFlat = UiStyles.panel(color, 9, Color("6637b7") if index == session.index else Color.WHITE)
				dot_style.set_content_margin_all(0.0)
				dot.add_theme_stylebox_override("normal", dot_style)
				dots.add_child(dot)
			var progress: ProgressBar = ProgressBar.new()
			progress.name = "RoundProgress"
			progress.max_value = GameSession.ROUND_SIZE
			progress.value = session.results.size()
			progress.show_percentage = false
			progress.custom_minimum_size.y = 4
			var track_style: StyleBoxFlat = UiStyles.panel(Color.WHITE, 3)
			track_style.set_content_margin_all(0.0)
			var fill_style: StyleBoxFlat = UiStyles.panel(Color("328778"), 3, Color("328778"))
			fill_style.set_content_margin_all(0.0)
			progress.add_theme_stylebox_override("background", track_style)
			progress.add_theme_stylebox_override("fill", fill_style)
			middle.add_child(progress)
	var sound: Button = _icon_button(SOUND_ON if audio.enabled else SOUND_OFF, "Desligar som" if audio.enabled else "Ligar som")
	sound.name = "SoundToggle"
	sound.toggle_mode = true
	sound.button_pressed = audio.enabled
	sound.pressed.connect(_toggle_sound)
	header.add_child(sound)


func _build_menu(stage: VBoxContainer) -> void:
	var layout: BoxContainer = HBoxContainer.new() if _landscape else VBoxContainer.new()
	layout.add_theme_constant_override("separation", 18 if _landscape else 12)
	stage.add_child(layout)
	var introduction: VBoxContainer = VBoxContainer.new()
	introduction.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	introduction.alignment = BoxContainer.ALIGNMENT_CENTER
	introduction.add_theme_constant_override("separation", 4)
	layout.add_child(introduction)
	if not _compact:
		introduction.add_child(UiStyles.label("UMA LETRA, MUITAS DESCOBERTAS", 10))
	introduction.add_child(UiStyles.label("Alfabeto", 34 if _compact else 42))
	var title: Label = UiStyles.label("Divertido", 38 if _compact else 46)
	title.add_theme_color_override("font_color", Color("6637b7"))
	introduction.add_child(title)
	var subtitle: Label = UiStyles.label("Vamos aprender a ler brincando!", 14 if _compact else 17)
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	introduction.add_child(subtitle)
	if not _compact or _landscape:
		var art: HBoxContainer = HBoxContainer.new()
		art.alignment = BoxContainer.ALIGNMENT_CENTER
		art.add_theme_constant_override("separation", 10)
		introduction.add_child(art)
		for index: int in range(3):
			var letter: Label = UiStyles.label("ABC"[index], 30)
			letter.custom_minimum_size = Vector2(45, 46)
			letter.add_theme_stylebox_override("normal", UiStyles.panel(UiStyles.COLORS[index], 14))
			art.add_child(letter)
	var modes: VBoxContainer = VBoxContainer.new()
	modes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	modes.add_theme_constant_override("separation", 10)
	layout.add_child(modes)
	var colors: Array[Color] = [UiStyles.PINK, UiStyles.MINT, UiStyles.PURPLE]
	var symbols: PackedStringArray = ["A", "AB", "Z"]
	for mode: int in range(3):
		var button: Button = UiStyles.button("", colors[mode], 20)
		button.name = "Mode%d" % mode
		button.add_to_group("mode_button")
		button.custom_minimum_size.y = 60 if _landscape and _compact else 66 if _compact else 72
		button.tooltip_text = MODE_NAMES[mode]
		button.accessibility_name = MODE_NAMES[mode]
		button.pressed.connect(start_mode.bind(mode))
		modes.add_child(button)
		var inside: HBoxContainer = HBoxContainer.new()
		button.add_child(inside)
		inside.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		inside.offset_left = 12
		inside.offset_right = -10
		inside.add_theme_constant_override("separation", 10)
		inside.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var icon: Label = UiStyles.label(symbols[mode], 23)
		icon.custom_minimum_size.x = 38
		inside.add_child(icon)
		var description: VBoxContainer = VBoxContainer.new()
		description.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		description.alignment = BoxContainer.ALIGNMENT_CENTER
		description.add_theme_constant_override("separation", 1)
		description.mouse_filter = Control.MOUSE_FILTER_IGNORE
		inside.add_child(description)
		var name_label: Label = UiStyles.label(MODE_NAMES[mode], 16 if _compact else 18)
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		description.add_child(name_label)
		var hint: Label = UiStyles.label(MODE_HINTS[mode], 11 if _compact else 12)
		hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		description.add_child(hint)
	if not _landscape:
		var note: Label = UiStyles.label("Feito para explorar, tentar e aprender", 11)
		stage.add_child(note)


func _build_game(stage: VBoxContainer) -> void:
	var panel: PanelContainer = PanelContainer.new()
	panel.name = "ActivityPanel"
	var panel_style: StyleBoxFlat = UiStyles.panel(Color("ffffffd9"), 24)
	if _landscape and _compact:
		panel_style.set_content_margin_all(4.0)
	panel.add_theme_stylebox_override("panel", panel_style)
	stage.add_child(panel)
	var body: VBoxContainer = VBoxContainer.new()
	body.add_theme_constant_override("separation", 4 if _landscape and _compact else 8 if _compact else 12)
	panel.add_child(body)
	if session.mode == GameSession.Mode.ALPHABET:
		_build_alphabet(body)
	else:
		_build_question(body)
	_feedback = UiStyles.label(_feedback_text, 14 if _compact else 17)
	_feedback.name = "Feedback"
	_feedback.add_theme_color_override("font_color", _feedback_color)
	_feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_feedback.custom_minimum_size.y = 34 if _compact else 44
	if session.mode == GameSession.Mode.ALPHABET:
		_feedback.custom_minimum_size.y = 22
		_feedback.visible = not _landscape or not _compact
	body.add_child(_feedback)


func _build_question(body: VBoxContainer) -> void:
	var card: WordCard = session.current_card()
	var prompt: String = "Monte a palavra: %s" % card.word if session.mode == GameSession.Mode.WORD else "Qual é a primeira letra de %s?" % card.word
	var question: Label = UiStyles.label(prompt, 20 if _compact else 24)
	question.name = "Question"
	question.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_child(question)
	var row: BoxContainer = HBoxContainer.new() if _landscape else VBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	body.add_child(row)
	var dimensions: float = 72.0 if _compact else 100.0
	var image: TextureRect = UiStyles.image(card.illustration, Vector2(dimensions, dimensions))
	image.name = "WordIllustration"
	row.add_child(image)
	var answers: VBoxContainer = VBoxContainer.new()
	answers.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	answers.alignment = BoxContainer.ALIGNMENT_CENTER
	answers.add_theme_constant_override("separation", 12)
	row.add_child(answers)
	if session.mode == GameSession.Mode.INITIAL:
		answers.add_child(UiStyles.label(card.word if session.is_complete else "?" + card.word.substr(1), 30 if _compact else 38))
	else:
		var slots: HBoxContainer = HBoxContainer.new()
		slots.alignment = BoxContainer.ALIGNMENT_CENTER
		slots.add_theme_constant_override("separation", 7)
		answers.add_child(slots)
		for index: int in range(card.word.length()):
			var slot: Label = UiStyles.label(card.word[index] if index < session.position else "", 26)
			slot.custom_minimum_size = Vector2(48, 48)
			var color: Color = UiStyles.YELLOW if index < session.position else Color.WHITE
			slot.add_theme_stylebox_override("normal", UiStyles.panel(color, 12, Color("6637b7") if index == session.position else Color("b6bdc5")))
			slots.add_child(slot)
			_slots.append(slot)
	var options: HBoxContainer = HBoxContainer.new()
	options.name = "Letters"
	options.alignment = BoxContainer.ALIGNMENT_CENTER
	options.add_theme_constant_override("separation", 8)
	answers.add_child(options)
	var letters: PackedStringArray = session.choices if session.mode == GameSession.Mode.INITIAL else session.occurrences
	for index: int in range(letters.size()):
		var letter: Button = UiStyles.letter_button(letters[index], UiStyles.COLORS[index % 3], 28)
		letter.name = "Letter%d" % index
		letter.tooltip_text = "Letra %s" % letters[index]
		letter.accessibility_name = letter.tooltip_text
		letter.custom_minimum_size = Vector2(56 if _compact else 64, 66 if _compact else 76)
		letter.disabled = session.is_complete or (session.mode == GameSession.Mode.WORD and session.used[index])
		if session.mode == GameSession.Mode.WORD:
			letter.pressed.connect(choose_occurrence.bind(index))
		else:
			letter.pressed.connect(choose_initial.bind(letters[index]))
		if session.is_complete and (session.mode == GameSession.Mode.WORD or letters[index] == card.word[0]):
			var correct_style: StyleBoxFlat = UiStyles.panel(UiStyles.GREEN, 16)
			correct_style.content_margin_top = 20.0
			correct_style.content_margin_bottom = 2.0
			letter.add_theme_stylebox_override("disabled", correct_style)
		options.add_child(letter)
		_responses.append(letter)


func _build_alphabet(body: VBoxContainer) -> void:
	if not _compact:
		body.add_child(UiStyles.label("Brincar com o Alfabeto", 24))
	var top: HBoxContainer = HBoxContainer.new()
	top.alignment = BoxContainer.ALIGNMENT_CENTER
	top.add_theme_constant_override("separation", 10)
	body.add_child(top)
	var instruction: Label = UiStyles.label("Toque em uma letra para ouvir", 12 if _compact else 15)
	instruction.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	instruction.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(instruction)
	var card_box: PanelContainer = PanelContainer.new()
	card_box.name = "AlphabetCard"
	var card_style: StyleBoxFlat = UiStyles.panel(Color("fff8dc"), 16, Color("d8b951"))
	if _landscape and _compact:
		card_style.set_content_margin_all(3.0)
	card_box.add_theme_stylebox_override("panel", card_style)
	card_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card_box.size_flags_stretch_ratio = 2.0
	top.add_child(card_box)
	var content: HBoxContainer = HBoxContainer.new()
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 6)
	card_box.add_child(content)
	if selected_letter >= 0:
		var card: WordCard = CATALOG.examples[selected_letter]
		content.add_child(UiStyles.label(card.letter, 24 if _compact else 30))
		content.add_child(UiStyles.image(card.illustration, Vector2(32 if _compact else 44, 32 if _compact else 44)))
		var word: Label = UiStyles.label(card.word, 12 if _compact else 14)
		word.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		word.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		content.add_child(word)
	else:
		content.add_child(UiStyles.label("A · B · C", 24))
	var grid: GridContainer = GridContainer.new()
	grid.name = "AlphabetGrid"
	grid.columns = 10 if _landscape else 5 if size.x < 350.0 else 6
	grid.add_theme_constant_override("h_separation", 4)
	grid.add_theme_constant_override("v_separation", 4)
	body.add_child(grid)
	for index: int in range(26):
		var letter: Button = UiStyles.button(CATALOG.examples[index].letter, UiStyles.COLORS[index % 3], 22)
		letter.name = "Alphabet%d" % index
		letter.tooltip_text = "Letra %s" % CATALOG.examples[index].letter
		letter.accessibility_name = letter.tooltip_text
		letter.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		letter.toggle_mode = true
		letter.button_pressed = selected_letter == index
		if selected_letter == index:
			letter.add_theme_stylebox_override("normal", UiStyles.panel(UiStyles.YELLOW, 16, Color("6637b7")))
			letter.add_theme_stylebox_override("pressed", UiStyles.panel(UiStyles.YELLOW, 16, Color("6637b7")))
		letter.pressed.connect(select_letter.bind(index))
		grid.add_child(letter)
		_responses.append(letter)


func _build_celebration(stage: VBoxContainer) -> void:
	var panel: PanelContainer = PanelContainer.new()
	var panel_style: StyleBoxFlat = UiStyles.panel(Color("ffffffd9"), 24)
	if _landscape and _compact:
		panel_style.set_content_margin_all(4.0)
	panel.add_theme_stylebox_override("panel", panel_style)
	stage.add_child(panel)
	var body: VBoxContainer = VBoxContainer.new()
	body.add_theme_constant_override("separation", 4 if _landscape and _compact else 10)
	panel.add_child(body)
	var count: int = GameSession.stars_for(session.first_attempts)
	var stars: HBoxContainer = HBoxContainer.new()
	stars.alignment = BoxContainer.ALIGNMENT_CENTER
	stars.add_theme_constant_override("separation", 12)
	body.add_child(stars)
	for index: int in range(3):
		var star: Label = UiStyles.label("★", 44 if _compact else 66)
		star.add_theme_color_override("font_color", Color("b27600") if index < count else Color("a7b2bd"))
		stars.add_child(star)
	var titles: PackedStringArray = ["Boa! Continue!", "Muito bem!", "Uau! Que incrível!"]
	var messages: PackedStringArray = ["Cada tentativa te deixa mais forte. Vamos de novo?", "Você está aprendendo muito rápido!", "Você acertou quase tudo de primeira. Que memória boa!"]
	body.add_child(UiStyles.label(titles[count - 1], 26 if _compact else 32))
	body.add_child(UiStyles.label("%d de 3 estrelas" % count, 12))
	var message: Label = UiStyles.label(messages[count - 1], 15 if _compact else 19)
	message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_child(message)
	var actions: HBoxContainer = HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_theme_constant_override("separation", 10)
	body.add_child(actions)
	var replay: Button = UiStyles.button("Jogar de novo", UiStyles.MINT, 16)
	replay.name = "Replay"
	replay.pressed.connect(start_mode.bind(session.mode))
	actions.add_child(replay)
	var menu: Button = UiStyles.button("Menu", UiStyles.PURPLE, 16)
	menu.pressed.connect(back_to_menu)
	actions.add_child(menu)
	_responses.append(replay)


func _build_footer() -> void:
	var footer: HBoxContainer = HBoxContainer.new()
	footer.name = "Footer"
	footer.add_theme_constant_override("separation", 8)
	_frame.add_child(footer)
	if screen != Screen.MENU:
		var mascot: VBoxContainer = VBoxContainer.new()
		mascot.add_theme_constant_override("separation", 0)
		footer.add_child(mascot)
		_mascot_image = MascotAnimation.new()
		_mascot_image.name = "MascotAnimation"
		_mascot_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_mascot_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_mascot_image.custom_minimum_size = Vector2(40, 30) if _landscape and _compact else Vector2(54, 60)
		_mascot_image.motion_enabled = _motion_enabled
		mascot.add_child(_mascot_image)
		_mascot_image.play(_mascot_reaction)
		var mascot_name: Label = UiStyles.label("Rômulo Penha", 8)
		mascot_name.name = "MascotName"
		mascot.add_child(mascot_name)
		_bubble = UiStyles.label(_mascot_text, 11 if _compact else 14)
		_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_bubble.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		footer.add_child(_bubble)
	if screen == Screen.MENU:
		var credit: Label = UiStyles.label("Jogo desenvolvido por \"Rômulo Penha\"\nTwemoji © Twitter · CC BY 4.0 | Nunito · OFL", 9)
		credit.name = "AuthorCredit"
		credit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		footer.add_child(credit)


func _icon_button(texture: Texture2D, description: String) -> Button:
	var button: Button = UiStyles.button("", Color.WHITE)
	button.icon = texture
	button.expand_icon = true
	button.add_theme_constant_override("icon_max_width", 27)
	button.tooltip_text = description
	button.accessibility_name = description
	return button


func _toggle_sound() -> void:
	audio.set_enabled(not audio.enabled)
	var button: Button = _frame.get_node("Header/SoundToggle") as Button
	button.icon = SOUND_ON if audio.enabled else SOUND_OFF
	button.button_pressed = audio.enabled
	button.tooltip_text = "Desligar som" if audio.enabled else "Ligar som"
	button.accessibility_name = button.tooltip_text


func _toggle_motion() -> void:
	_motion_enabled = not _motion_enabled
	if not _motion_enabled:
		_stop_tweens()
	var button: Button = _frame.get_node("Header/MotionToggle") as Button
	button.button_pressed = not _motion_enabled
	button.tooltip_text = "Reduzir movimentos" if _motion_enabled else "Ativar movimentos"


func _focus_default() -> void:
	if screen == Screen.MENU:
		var buttons: Array[Node] = get_tree().get_nodes_in_group("mode_button")
		if not buttons.is_empty():
			(buttons[0] as Button).grab_focus()
	elif screen == Screen.GAME and session.mode == GameSession.Mode.ALPHABET and selected_letter >= 0:
		_responses[selected_letter].grab_focus()
	else:
		for button: Button in _responses:
			if not button.disabled:
				button.grab_focus()
				return
		var home: Button = _frame.get_node("Header").get_child(0) as Button
		home.grab_focus()


func _pop(control: Control) -> void:
	if not _motion_enabled or not is_instance_valid(control):
		return
	control.pivot_offset = control.size / 2.0
	var tween: Tween = create_tween()
	tween.tween_property(control, "scale", Vector2(1.08, 1.08), 0.12)
	tween.tween_property(control, "scale", Vector2.ONE, 0.2)
	_tweens.append(tween)


func _stop_tweens() -> void:
	for tween: Tween in _tweens:
		if tween.is_valid():
			tween.kill()
	_tweens.clear()
