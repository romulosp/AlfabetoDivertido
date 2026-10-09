extends SceneTree

const Progress = preload("res://scripts/progress_store.gd")
var failures: PackedStringArray = []
var checks: int = 0

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var audio: Node = root.get_node("AudioService")
	var progress: Node = root.get_node("ProgressService")
	var original_store: RefCounted = progress.store
	progress.store = Progress.new("user://test_integration.json")
	progress.store.reset_test_files()
	progress.store.load_progress()
	var store: RefCounted = Progress.new("user://test_progress.json")
	store.reset_test_files()
	check(store.load_progress(), "novo perfil")
	check(store.complete_activity("bola"), "salvar bola")
	check(store.complete_activity("casa"), "salvar casa")
	var broken: FileAccess = FileAccess.open("user://test_progress.json", FileAccess.WRITE)
	broken.store_string("invalid")
	broken.close()
	var recovered: RefCounted = Progress.new("user://test_progress.json")
	check(recovered.load_progress(), "recupera backup")
	check("bola" in recovered.data.completedActivities, "backup preserva progresso")
	var migrated: Dictionary = store.migrate({"schemaVersion":1,"completedActivities":["dado"]})
	check(migrated.schemaVersion == 2 and "dado" in migrated.completedActivities, "migração")
	check(store.migrate({"schemaVersion":99}).is_empty(), "esquema futuro protegido")
	check(store.migrate({"schemaVersion":2,"audioSettings":[]}).is_empty(), "preferências inválidas protegidas")
	var scene: Node = load("res://scenes/World.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	for concept: String in ["bola", "casa", "dado"]:
		scene.open_activity(concept)
		await process_frame
		check(scene.active_concept == concept, "abre atividade")
		scene.answer("Z")
		check(not scene.activity_complete, "erro permite nova tentativa")
		scene.give_hint()
		scene.repeat_speech()
		scene.answer(concept[0].to_upper())
		check(scene.activity_complete, "resposta correta")
		scene.return_to_world()
		await process_frame
	check(scene.active_concept.is_empty(), "retorna jardim")
	var previous_destination: Vector3 = scene.destination
	var click: InputEventMouseButton = InputEventMouseButton.new()
	click.position = (scene.overlay.get_child(0) as Button).get_global_rect().get_center()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	root.push_input(click, true)
	click.pressed = false
	root.push_input(click, true)
	await process_frame
	check(scene.destination == previous_destination, "UI consome toque antes do mundo")
	audio.speak("welcome")
	audio.speak("bola_prompt")
	check(audio.current_id == "bola_prompt", "nova fala cancela anterior")
	audio.stop()
	check(not audio.is_speaking(), "fala cancelada")
	check(ProjectSettings.get_setting("display/window/handheld/orientation") == 0, "paisagem")
	check(scene.has_method("_unhandled_input"), "mundo somente após UI")
	check(scene._skeleton != null and scene._skeleton.find_bone("DEF-beak") >= 0, "rig do bico importado")
	check(scene._animation_player != null and scene._animation_player.has_animation("talk"), "animação de fala importada")
	var jaw: int = scene._skeleton.find_bone("DEF-beak")
	var modifier: SkeletonModifier3D = scene._skeleton.get_child(scene._skeleton.get_child_count() - 1) as SkeletonModifier3D
	check(modifier != null, "bico usa modificador após animação")
	modifier.preview_opening = 0.60
	await process_frame
	await process_frame
	check(modifier.closed_rotation.angle_to(Quaternion.IDENTITY) > 0.1, "repouso GLB preservado em vez de identidade")
	check(modifier.opening > 0.5, "bico abre mesmo com AnimationPlayer ativo")
	modifier.preview_opening = 0.0
	await process_frame
	await process_frame
	check(is_zero_approx(modifier.opening), "bico fecha no silêncio")
	modifier.preview_opening = -1.0
	audio.speak("welcome")
	var observed: Array[int] = []
	for sample: int in range(12):
		await create_timer(0.08).timeout
		var pose_code: int = int(round(modifier.opening * 100.0))
		if not observed.has(pose_code):
			observed.append(pose_code)
	check(audio.is_speaking() and observed.size() >= 2, "bico muda durante reprodução real do áudio")
	audio.stop()
	await process_frame
	await process_frame
	check(is_zero_approx(modifier.opening), "interromper áudio fecha bico automaticamente")
	check(scene.overlay.get_node("TutorPortrait") != null, "tutor visível fora do painel da atividade")
	scene.free()
	audio.effects.stop()
	audio.voice.stream = null
	audio.effects.stream = null
	progress.store.reset_test_files()
	progress.store = original_store
	store.reset_test_files()
	await process_frame
	await process_frame
	await create_timer(0.4).timeout
	print(JSON.stringify({"suite":"3d_runtime","checks":checks,"failures":failures}))
	quit.call_deferred(0 if failures.is_empty() else 1)

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures.append(message)
		push_error(message)
