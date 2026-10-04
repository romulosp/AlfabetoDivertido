class_name MascotAnimation
extends TextureRect

## Plays the transparent frames authored and rendered in Blender.

const FRAMES: SpriteFrames = preload("res://assets/mascot/animations.tres")

var motion_enabled: bool = true
var animation: StringName = &"idle"
var _elapsed: float = 0.0
var _frame_index: int = 0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	accessibility_name = "Rômulo Penha, o tucano mascote"
	texture = FRAMES.get_frame_texture(&"idle", 0)


func _process(delta: float) -> void:
	if not motion_enabled:
		texture = FRAMES.get_frame_texture(&"idle", 0)
		return
	_elapsed += delta
	var step: float = 1.0 / FRAMES.get_animation_speed(animation)
	while _elapsed >= step:
		_elapsed -= step
		_frame_index += 1
		if _frame_index >= FRAMES.get_frame_count(animation):
			_frame_index = 0
			if not FRAMES.get_animation_loop(animation):
				animation = &"idle"
		texture = FRAMES.get_frame_texture(animation, _frame_index)


func play(reaction: StringName) -> void:
	animation = reaction if FRAMES.has_animation(reaction) else &"idle"
	_elapsed = 0.0
	_frame_index = 0
	texture = FRAMES.get_frame_texture(animation, 0)
