extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	root.mode = Window.MODE_WINDOWED
	root.size = Vector2i(1280,720)
	var scene: Node = load("res://scenes/World.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://../docs/evidence/3d-menu.png")
	scene.return_to_world()
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://../docs/evidence/3d-garden.png")
	for concept: String in ["bola","casa","dado"]:
		scene.open_activity(concept)
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://../docs/evidence/3d-"+concept+".png")
	root.get_node("AudioService").stop()
	var portrait: SubViewport = scene.overlay.get_node("TutorPortrait").get_child(0) as SubViewport
	var skeleton: Skeleton3D = portrait.get_child(0).find_children("*", "Skeleton3D", true, false)[0] as Skeleton3D
	var jaw: Node = skeleton.get_child(skeleton.get_child_count() - 1)
	for pose: float in [0.0, 0.6]:
		jaw.preview_opening = pose
		await process_frame
		await process_frame
		await RenderingServer.frame_post_draw
		portrait.get_texture().get_image().save_png("res://../docs/evidence/tutor-mouth-" + ("closed" if pose == 0.0 else "open") + ".png")
	root.get_node("AudioService").voice.stream = null
	scene.free()
	await process_frame
	await create_timer(0.4).timeout
	quit.call_deferred()
