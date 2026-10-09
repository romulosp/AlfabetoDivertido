class_name LetterGarden
extends Node3D

var active_concept: String = ""
var activity_complete: bool = false
var camera: Camera3D
var player: Node3D
var tutor: Node3D
var destination: Vector3 = Vector3(0, 0, 3)
var overlay: Control
var panel: PanelContainer
var subtitle: Label
var progress_label: Label
var prompt_label: Label
var hint_timer: Timer
var menu_visible: bool = true
var options: Array[Button] = []
var object_nodes: Dictionary[String, Node3D] = {}
var tutor_state: StringName = &"idle"
var _hint_level: int = 0
var _speech_id: String = "welcome"
var _elapsed: float = 0.0
var _beak: Node3D
var _skeleton: Skeleton3D
var _animation_player: AnimationPlayer
var _last_animation: StringName = &""
var _portrait_animation: AnimationPlayer
var _portrait_last_animation: StringName = &""
var _settings: PanelContainer
var _measurement_frames: int = 0
var _measurement_seconds: float = 0.0
var _measured: bool = false

const COLORS: Array[Color] = [Color("ef8ca7"),Color("71d8d0"),Color("f8d967")]

func _ready() -> void:
	get_tree().auto_accept_quit = false
	get_tree().quit_on_go_back = false
	_build_garden()
	_build_ui()
	EventBus.speech_changed.connect(_on_speech)
	EventBus.speech_finished.connect(_on_speech_finished)
	hint_timer = Timer.new()
	hint_timer.wait_time = 12.0
	hint_timer.timeout.connect(give_hint)
	add_child(hint_timer)
	_show_menu()
	print(JSON.stringify({"event":"garden_ready","concepts":CatalogService.concepts.size(),"ticks":Time.get_ticks_msec()}))

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if not active_concept.is_empty():
			return_to_world()
		elif not menu_visible:
			_show_menu()
		else:
			get_tree().quit()
	elif what == NOTIFICATION_APPLICATION_PAUSED and is_instance_valid(AudioService):
		AudioService.stop()

func _process(delta: float) -> void:
	_elapsed += delta
	if not _measured:
		_measurement_frames += 1
		_measurement_seconds += delta
		if _measurement_seconds >= 10.0:
			_measured = true
			print(JSON.stringify({"event":"performance_sample","seconds":_measurement_seconds,"frames":_measurement_frames,"averageFps":float(_measurement_frames)/_measurement_seconds,"staticMemoryBytes":Performance.get_monitor(Performance.MEMORY_STATIC),"scope":"first_ten_seconds"}))
	if not menu_visible and active_concept.is_empty():
		player.position = player.position.move_toward(destination, delta * 3.0)
		var following: Vector3 = player.position + Vector3(-1.1,0,-0.4)
		tutor.position = tutor.position.move_toward(following, delta * 2.7)
	if is_instance_valid(_portrait_animation):
		var portrait_clip: StringName = &"talk" if AudioService.is_speaking() else &"idle"
		if portrait_clip != _portrait_last_animation:
			_portrait_animation.play(portrait_clip, 0.1)
			_portrait_last_animation = portrait_clip
	if is_instance_valid(_animation_player):
		var clip: StringName = &"talk" if AudioService.is_speaking() else &"celebrate" if tutor_state == &"celebrating" else &"think" if tutor_state == &"helping" else &"idle"
		if ProgressService.store.data.accessibilitySettings.get("reducedMotion",false):
			_animation_player.stop()
		elif clip != _last_animation and _animation_player.has_animation(clip):
			_animation_player.play(clip,0.15)
			_last_animation = clip
	if is_instance_valid(tutor) and not ProgressService.store.data.accessibilitySettings.get("reducedMotion", false):
		var model: Node3D = tutor.get_child(0) as Node3D
		model.position.y = sin(_elapsed * 2.0) * (0.10 if tutor_state == &"celebrating" else 0.015)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if not active_concept.is_empty():
			return_to_world()
		else:
			_show_menu()
		return
	if menu_visible or not active_concept.is_empty():
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		world_touch(event.position)

func world_touch(point: Vector2) -> void:
	var origin: Vector3 = camera.project_ray_origin(point)
	var direction: Vector3 = camera.project_ray_normal(point)
	var plane: Plane = Plane(Vector3.UP, 0.0)
	var hit: Variant = plane.intersects_ray(origin, direction)
	if hit == null:
		return
	var location: Vector3 = hit
	for concept_id: String in object_nodes:
		if location.distance_to(object_nodes[concept_id].position) < 1.7:
			open_activity(concept_id)
			return
	if location.length() <= 7.0:
		destination = Vector3(clampf(location.x,-5.0,5.0),0,clampf(location.z,-4.0,4.0))

func _build_garden() -> void:
	var environment: WorldEnvironment = WorldEnvironment.new()
	environment.environment = Environment.new()
	environment.environment.background_mode = Environment.BG_COLOR
	environment.environment.background_color = Color("bce8ee")
	environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.environment.ambient_light_color = Color("fff4df")
	environment.environment.ambient_light_energy = 0.35
	add_child(environment)
	var sunlight: DirectionalLight3D = DirectionalLight3D.new()
	sunlight.rotation_degrees = Vector3(-55,-35,0)
	sunlight.light_energy = 0.7
	sunlight.shadow_enabled = true
	add_child(sunlight)
	camera = Camera3D.new()
	camera.position = Vector3(10,15,18)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 19.0
	add_child(camera)
	camera.look_at(Vector3(0,0,0))
	camera.current = true
	var island: CylinderMesh = CylinderMesh.new()
	island.top_radius = 8.0
	island.bottom_radius = 7.7
	island.height = 0.7
	_mesh(self,island,Vector3(0,-0.42,0),Color("72bca0"))
	var soil: CylinderMesh = CylinderMesh.new()
	soil.top_radius = 7.8
	soil.bottom_radius = 6.8
	soil.height = 1.1
	_mesh(self,soil,Vector3(0,-1.1,0),Color("bf9871"))
	for index: int in range(16):
		var angle: float = float(index) * TAU / 16.0
		var stone: SphereMesh = SphereMesh.new()
		stone.radius = 0.35
		stone.height = 0.3
		_mesh(self,stone,Vector3(cos(angle)*5.7,0.02,sin(angle)*4.3),Color("ece6ce"))
	for pos: Vector3 in [Vector3(-5,0,-3),Vector3(5,0,-3),Vector3(-6,0,1),Vector3(5.5,0,2.5)]:
		var trunk: CylinderMesh = CylinderMesh.new()
		trunk.top_radius = 0.13
		trunk.bottom_radius = 0.2
		trunk.height = 1.4
		_mesh(self,trunk,pos+Vector3(0,0.7,0),Color("936646"))
		var leaves: SphereMesh = SphereMesh.new()
		leaves.radius = 0.9
		leaves.height = 1.7
		_mesh(self,leaves,pos+Vector3(0,1.9,0),Color("3b916b"))
	var positions: Array[Vector3] = [Vector3(-3,0,0),Vector3(0,0,-2.7),Vector3(3.4,0,0)]
	for index: int in range(CatalogService.concepts.size()):
		var concept: Dictionary = CatalogService.concepts[index]
		var object: Node3D = Node3D.new()
		object.name = concept.conceptId.capitalize()
		object.position = positions[index]
		add_child(object)
		object_nodes[concept.conceptId] = object
		_build_object(object,concept.conceptId)
		var label: Label3D = Label3D.new()
		label.text = "%s · %s" % [concept.letter,concept.namePt.to_upper()]
		label.position.y = 2.3
		label.font_size = 64
		label.pixel_size = 0.012
		label.outline_size = 8
		label.modulate = Color("ffffff")
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		object.add_child(label)
	player = Node3D.new()
	player.position = destination
	add_child(player)
	var body: CapsuleMesh = CapsuleMesh.new()
	body.radius = 0.32
	body.height = 1.1
	_mesh(player,body,Vector3(0,0.55,0),Color("e8a668"))
	var head: SphereMesh = SphereMesh.new()
	head.radius = 0.28
	head.height = 0.56
	_mesh(player,head,Vector3(0,1.22,0),Color("fff0cf"))
	tutor = Node3D.new()
	tutor.name = "Tutor"
	tutor.position = Vector3(-1.2,0,3)
	add_child(tutor)
	if ResourceLoader.exists("res://assets/models/tucano.glb"):
		var tutor_scene: PackedScene = load("res://assets/models/tucano.glb") as PackedScene
		var model: Node3D = tutor_scene.instantiate() as Node3D
		tutor.add_child(model)
		model.scale = Vector3.ONE * 1.15
		_beak = model.find_child("BeakLower",true,false) as Node3D
		for descendant: Node in model.find_children("*","Skeleton3D",true,false):
			_skeleton = descendant as Skeleton3D
			_skeleton.add_child(load("res://scripts/tutor_jaw.gd").new())
		for descendant: Node in model.find_children("*","AnimationPlayer",true,false):
			_animation_player = descendant as AnimationPlayer
		if is_instance_valid(_animation_player):
			for clip_name: String in _animation_player.get_animation_list():
				if clip_name in ["idle","talk"]:
					_animation_player.get_animation(clip_name).loop_mode = Animation.LOOP_LINEAR
	else:
		var provisional: Node3D = Node3D.new()
		tutor.add_child(provisional)
		var bird: SphereMesh = SphereMesh.new()
		bird.radius = 0.4
		bird.height = 1.0
		_mesh(provisional,bird,Vector3(0,0.7,0),Color("203546"))
	var tutor_name: Label3D = Label3D.new()
	tutor_name.text = "Rômulo Penha"
	tutor_name.position.y = 1.9
	tutor_name.font_size = 30
	tutor_name.pixel_size = 0.009
	tutor_name.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	tutor.add_child(tutor_name)

func _build_object(parent: Node3D, concept_id: String) -> void:
	if concept_id == "bola":
		var sphere: SphereMesh = SphereMesh.new()
		sphere.radius = 0.65
		sphere.height = 1.3
		_mesh(parent,sphere,Vector3(0,0.7,0),Color("f3919c"))
		var band: TorusMesh = TorusMesh.new()
		band.inner_radius = 0.61
		band.outer_radius = 0.68
		_mesh(parent,band,Vector3(0,0.7,0),Color("ffdd6c"))
	elif concept_id == "casa":
		var house: BoxMesh = BoxMesh.new()
		house.size = Vector3(1.6,1.3,1.4)
		_mesh(parent,house,Vector3(0,0.65,0),Color("ffde90"))
		var roof: PrismMesh = PrismMesh.new()
		roof.size = Vector3(1.9,0.9,1.7)
		_mesh(parent,roof,Vector3(0,1.7,0),Color("d87879"))
		var door: BoxMesh = BoxMesh.new()
		door.size = Vector3(0.45,0.8,0.04)
		_mesh(parent,door,Vector3(0,0.42,0.72),Color("368e89"))
	else:
		var die: BoxMesh = BoxMesh.new()
		die.size = Vector3.ONE * 1.1
		_mesh(parent,die,Vector3(0,0.6,0),Color("fff7e8"))
		for spot: Vector3 in [Vector3(-0.27,0.35,0.565),Vector3(0.27,0.85,0.565),Vector3(0,0.6,0.565)]:
			var dot: SphereMesh = SphereMesh.new()
			dot.radius = 0.09
			dot.height = 0.18
			_mesh(parent,dot,spot,Color("33485a"))

func _mesh(parent: Node3D, mesh: Mesh, pos: Vector3, color: Color) -> MeshInstance3D:
	var node: MeshInstance3D = MeshInstance3D.new()
	node.mesh = mesh
	node.position = pos
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.85
	node.material_override = material
	parent.add_child(node)
	return node

func _build_ui() -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	add_child(layer)
	overlay = Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(overlay)
	var theme: Theme = Theme.new()
	var font: FontVariation = FontVariation.new()
	font.base_font = load("res://assets/fonts/nunito.ttf") as Font
	font.variation_opentype = {&"wght":750.0}
	font.variation_embolden = 0.6
	theme.default_font = font
	theme.default_font_size = 22
	overlay.theme = theme
	var home: Button = _button("Menu",Color("ffffff"))
	home.position = Vector2(16,12)
	home.pressed.connect(_show_menu)
	overlay.add_child(home)
	var settings: Button = _button("Som e movimento",Color("ffffff"))
	settings.position = Vector2(128,12)
	settings.pressed.connect(_show_settings)
	overlay.add_child(settings)
	progress_label = _label("Jardim das Letras",22)
	progress_label.position = Vector2(440,20)
	overlay.add_child(progress_label)
	panel = PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.offset_left = -300
	panel.offset_right = 300
	panel.offset_top = -155
	panel.offset_bottom = 155
	panel.add_theme_stylebox_override("panel",_style(Color("fffaf0")))
	overlay.add_child(panel)
	var bottom: PanelContainer = PanelContainer.new()
	bottom.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	bottom.offset_left = 16
	bottom.offset_right = -16
	bottom.offset_top = -102
	bottom.offset_bottom = -20
	bottom.add_theme_stylebox_override("panel",_style(Color("fffaf0")))
	overlay.add_child(bottom)
	var row: HBoxContainer = HBoxContainer.new()
	bottom.add_child(row)
	subtitle = _label("",20)
	subtitle.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	row.add_child(subtitle)
	var repeat_button: Button = _button("Repetir",Color("d8f3e8"))
	repeat_button.pressed.connect(repeat_speech)
	row.add_child(repeat_button)
	_build_tutor_portrait()

func _build_tutor_portrait() -> void:
	var container: SubViewportContainer = SubViewportContainer.new()
	container.name = "TutorPortrait"
	container.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	container.offset_left = -176
	container.offset_right = -8
	container.offset_top = 94
	container.offset_bottom = 294
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	container.stretch = true
	overlay.add_child(container)
	var viewport: SubViewport = SubViewport.new()
	viewport.size = Vector2i(336, 400)
	viewport.transparent_bg = true
	viewport.own_world_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	container.add_child(viewport)
	var model: Node3D = (load("res://assets/models/tucano.glb") as PackedScene).instantiate() as Node3D
	viewport.add_child(model)
	for node: Node in model.find_children("*", "Skeleton3D", true, false):
		(node as Skeleton3D).add_child(load("res://scripts/tutor_jaw.gd").new())
	for node: Node in model.find_children("*", "AnimationPlayer", true, false):
		_portrait_animation = node as AnimationPlayer
		for clip: String in ["idle", "talk"]:
			_portrait_animation.get_animation(clip).loop_mode = Animation.LOOP_LINEAR
	var portrait_camera: Camera3D = Camera3D.new()
	viewport.add_child(portrait_camera)
	portrait_camera.position = Vector3(2.6, 1.6, 3.5)
	portrait_camera.look_at(Vector3(0.15, 0.85, 0))
	portrait_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	portrait_camera.size = 2.1
	var light: DirectionalLight3D = DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-35, -30, 0)
	light.light_energy = 1.0
	viewport.add_child(light)
	var environment_node: WorldEnvironment = WorldEnvironment.new()
	var environment: Environment = Environment.new()
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color.WHITE
	environment.ambient_light_energy = 0.45
	environment_node.environment = environment
	viewport.add_child(environment_node)

func _style(color: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(22)
	style.set_content_margin_all(14)
	return style

func _label(text: String, font_size: int) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.add_theme_color_override("font_color",Color("203546"))
	label.add_theme_font_size_override("font_size",font_size)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label

func _button(text: String, color: Color) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(96,52)
	button.add_theme_stylebox_override("normal",_style(color))
	button.add_theme_stylebox_override("hover",_style(color.lightened(0.12)))
	button.add_theme_stylebox_override("pressed",_style(color.darkened(0.08)))
	button.add_theme_color_override("font_color",Color("203546"))
	button.accessibility_name = text
	return button

func _clear_panel() -> VBoxContainer:
	for child: Node in panel.get_children():
		panel.remove_child(child)
		child.queue_free()
	options.clear()
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation",12)
	panel.add_child(box)
	panel.show()
	return box

func _show_menu() -> void:
	if not is_instance_valid(panel):
		return
	AudioService.stop()
	if is_instance_valid(hint_timer):
		hint_timer.stop()
	active_concept = ""
	menu_visible = true
	var box: VBoxContainer = _clear_panel()
	box.add_child(_label("Jardim das Letras",36))
	box.add_child(_label("Explore, descubra e aprenda com Rômulo Penha",18))
	var start: Button = _button("Vamos brincar!",Color("8ed8c4"))
	start.pressed.connect(return_to_world)
	box.add_child(start)
	box.add_child(_label("Jogo desenvolvido por \"Rômulo Penha\"",16))
	subtitle.text = "Toque em Vamos brincar para explorar o jardim."

func return_to_world() -> void:
	tutor_state = &"transitioning"
	AudioService.stop()
	hint_timer.stop()
	active_concept = ""
	menu_visible = false
	panel.hide()
	activity_complete = false
	progress_label.text = "%d de 3 descobertas" % ProgressService.store.data.completedActivities.size()
	_speech_id = "welcome"
	AudioService.speak(_speech_id)
	tutor_state = &"idle"

func open_activity(concept_id: String) -> void:
	var concept: Dictionary = CatalogService.get_concept(concept_id)
	if concept.is_empty():
		return
	active_concept = concept_id
	activity_complete = false
	menu_visible = false
	_hint_level = 0
	tutor_state = &"presenting"
	var box: VBoxContainer = _clear_panel()
	prompt_label = _label("Qual letra começa %s?" % concept.namePt.to_upper(),30)
	box.add_child(prompt_label)
	var illustration_path: String = concept.get("approvedImage", "")
	if not illustration_path.is_empty() and ResourceLoader.exists(illustration_path):
		var image: TextureRect = TextureRect.new()
		image.texture = load(illustration_path) as Texture2D
		image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		image.custom_minimum_size = Vector2(96,96)
		box.add_child(image)
	var choices: HBoxContainer = HBoxContainer.new()
	choices.alignment = BoxContainer.ALIGNMENT_CENTER
	choices.add_theme_constant_override("separation",16)
	box.add_child(choices)
	var letters: Array[String] = ["B","C","D"]
	letters.shuffle()
	for index: int in range(3):
		var option: Button = _button(letters[index],COLORS[index])
		option.custom_minimum_size = Vector2(112,74)
		option.pressed.connect(answer.bind(letters[index]))
		choices.add_child(option)
		options.append(option)
	var actions: HBoxContainer = HBoxContainer.new()
	box.add_child(actions)
	var hint: Button = _button("Dica",Color("ffecba"))
	hint.pressed.connect(give_hint)
	actions.add_child(hint)
	var back: Button = _button("Voltar ao jardim",Color("d8f3e8"))
	back.pressed.connect(return_to_world)
	actions.add_child(back)
	_speech_id = concept_id + "_prompt"
	AudioService.speak(_speech_id)
	hint_timer.start()

func answer(letter: String) -> void:
	if active_concept.is_empty() or activity_complete:
		return
	var concept: Dictionary = CatalogService.get_concept(active_concept)
	if letter == concept.letter:
		activity_complete = true
		hint_timer.stop()
		tutor_state = &"celebrating"
		ProgressService.complete_activity(active_concept)
		_speech_id = active_concept + "_correct"
		AudioService.speak(_speech_id)
		AudioService.play_effect(true)
		prompt_label.text = "Muito bem! %s começa com %s!" % [concept.namePt.capitalize(),letter]
		for option: Button in options:
			option.disabled = true
	else:
		tutor_state = &"helping"
		_speech_id = active_concept + "_wrong"
		AudioService.speak(_speech_id)
		AudioService.play_effect(false)
		hint_timer.start()

func give_hint() -> void:
	if active_concept.is_empty() or activity_complete:
		return
	_hint_level = mini(_hint_level + 1,2)
	tutor_state = &"helping"
	_speech_id = active_concept + "_hint" + str(_hint_level)
	AudioService.speak(_speech_id)
	var concept: Dictionary = CatalogService.get_concept(active_concept)
	for option: Button in options:
		if option.text == concept.letter and _hint_level == 2:
			option.grab_focus()

func repeat_speech() -> void:
	AudioService.speak(_speech_id)
	if not active_concept.is_empty():
		object_nodes[active_concept].scale = Vector3.ONE * 1.1

func _on_speech(text: String) -> void:
	subtitle.text = text

func _on_speech_finished() -> void:
	if tutor_state == &"presenting" or tutor_state == &"helping":
		tutor_state = &"waiting"

func _show_settings() -> void:
	if is_instance_valid(_settings):
		_settings.queue_free()
		return
	_settings = PanelContainer.new()
	_settings.position = Vector2(16,75)
	_settings.add_theme_stylebox_override("panel",_style(Color("fffaf0")))
	overlay.add_child(_settings)
	var box: VBoxContainer = VBoxContainer.new()
	_settings.add_child(box)
	for channel: String in ["voice","effects","music","ui"]:
		var names: Dictionary = {"voice":"Voz","effects":"Efeitos","music":"Música","ui":"Interface"}
		box.add_child(_label(names[channel],18))
		var slider: HSlider = HSlider.new()
		slider.custom_minimum_size = Vector2(260,48)
		slider.max_value = 1.0
		slider.step = 0.05
		slider.value = float(AudioService.volumes[channel])
		slider.value_changed.connect(_set_volume.bind(channel))
		box.add_child(slider)
	var motion: CheckButton = CheckButton.new()
	motion.text = "Reduzir movimentos"
	motion.custom_minimum_size.y = 48
	motion.button_pressed = ProgressService.store.data.accessibilitySettings.get("reducedMotion",false)
	motion.toggled.connect(_set_motion)
	box.add_child(motion)

func _set_volume(value: float, channel: String) -> void:
	AudioService.set_volume(channel,value)
	ProgressService.store.data.audioSettings = AudioService.volumes.duplicate()
	ProgressService.store.save()

func _set_motion(enabled: bool) -> void:
	ProgressService.store.data.accessibilitySettings.reducedMotion = enabled
	ProgressService.store.save()
