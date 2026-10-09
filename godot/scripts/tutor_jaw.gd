extends SkeletonModifier3D

var opening: float = 0.0
var preview_opening: float = -1.0
var closed_rotation: Quaternion = Quaternion.IDENTITY

func _ready() -> void:
	var model: Node = get_parent().get_parent()
	while model != null and model.find_children("*", "AnimationPlayer", true, false).is_empty():
		model = model.get_parent()
	if model == null:
		return
	for node: Node in model.find_children("*", "AnimationPlayer", true, false):
		var player: AnimationPlayer = node as AnimationPlayer
		var closed: Animation = player.get_animation("beak_closed")
		for track: int in range(closed.get_track_count()):
			if closed.track_get_type(track) == Animation.TYPE_ROTATION_3D and str(closed.track_get_path(track)).ends_with(":DEF-beak"):
				closed_rotation = closed.track_get_key_value(track, 0) as Quaternion

func _process_modification() -> void:
	var skeleton: Skeleton3D = get_skeleton()
	var jaw: int = skeleton.find_bone("DEF-beak")
	if jaw < 0:
		return
	opening = 0.0
	if preview_opening >= 0.0:
		opening = preview_opening
	elif AudioService.is_speaking():
		var time: float = AudioService.voice.get_playback_position()
		opening = [0.0, 0.32, 0.60][int(time * 8.0) % 3]
	# Modifiers run after AnimationPlayer, so its jaw track cannot erase this pose.
	skeleton.set_bone_pose_rotation(jaw, closed_rotation * Quaternion(Vector3.RIGHT, -opening))
