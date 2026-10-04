extends SceneTree

const MainScene: PackedScene = preload("res://scenes/main.tscn")

var _app: AlfabetoApp
var _checks: int = 0
var _failures: PackedStringArray = []
var _capture: bool = false


func _initialize() -> void:
	_capture = OS.get_cmdline_user_args().has("--capture")
	call_deferred("_run")


func _run() -> void:
	root.mode = Window.MODE_WINDOWED
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	root.content_scale_size = Vector2i.ZERO
	_app = MainScene.instantiate() as AlfabetoApp
	root.add_child(_app)
	await process_frame
	_app.audio.set_enabled(false)
	var dimensions: Array[Vector2i] = [Vector2i(320, 568), Vector2i(360, 640), Vector2i(390, 844), Vector2i(568, 320), Vector2i(640, 360), Vector2i(768, 1024), Vector2i(1024, 768)]
	for resolution: Vector2i in dimensions:
		root.size = resolution
		_app.size = Vector2(resolution)
		_app.back_to_menu()
		await _settle()
		_check_layout(resolution, "menu")
		await _screenshot(resolution, "menu")
		for mode: int in range(3):
			_app.start_mode(mode)
			if mode == GameSession.Mode.ALPHABET:
				_app.select_letter(7)
			await _settle()
			_check_layout(resolution, str(mode))
			await _screenshot(resolution, str(mode))
		_app.screen = AlfabetoApp.Screen.CELEBRATION
		_app.session.first_attempts = 8
		_app._render()
		await _settle()
		_check_layout(resolution, "celebration")
		await _screenshot(resolution, "celebration")
	print(JSON.stringify({"suite": "godot_layout", "checks": _checks, "failures": _failures}))
	_app.free()
	await process_frame
	quit(0 if _failures.is_empty() else 1)


func _settle() -> void:
	for frame: int in range(5):
		await process_frame


func _check_layout(resolution: Vector2i, activity: String) -> void:
	var nodes: Array[Node] = _app.find_children("*", "Control", true, false)
	for node: Node in nodes:
		var control: Control = node as Control
		if not control.is_visible_in_tree():
			continue
		var bounds: Rect2 = control.get_global_rect()
		if OS.get_cmdline_user_args().has("--diagnose") and resolution == Vector2i(568, 320) and activity == "2":
			print(JSON.stringify({"node": str(control.name), "rect": str(bounds), "minimum": str(control.get_combined_minimum_size())}))
		if control is Button or control is Label:
			var description: String = "%dx%d/%s/%s" % [resolution.x, resolution.y, activity, control.name]
			_check(bounds.position.x >= -0.5 and bounds.position.y >= -0.5 and bounds.end.x <= float(resolution.x) + 0.5 and bounds.end.y <= float(resolution.y) + 0.5, "sem corte: " + description + " " + str(bounds))
			if control is Button:
				_check(bounds.size.x >= 48 and bounds.size.y >= 48, "toque >=48: " + description)


func _screenshot(resolution: Vector2i, activity: String) -> void:
	if not _capture:
		return
	await RenderingServer.frame_post_draw
	var directory: String = ProjectSettings.globalize_path("res://../../tests/evidence/godot")
	DirAccess.make_dir_recursive_absolute(directory)
	var image: Image = root.get_texture().get_image()
	var path: String = "%s/%dx%d-%s.png" % [directory, resolution.x, resolution.y, activity]
	var error: Error = image.save_png(path)
	_check(error == OK, "captura " + path)


func _check(condition: bool, description: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(description)
		push_error(description)
