class_name LetterFace
extends Control


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(32, 14)
	set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	offset_left = -16.0
	offset_right = 16.0
	offset_top = 5.0
	offset_bottom = 19.0


func _draw() -> void:
	for center: Vector2 in [Vector2(9, 7), Vector2(23, 7)]:
		draw_circle(center, 6.0, Color.WHITE)
		draw_circle(center + Vector2(1, 1), 2.8, UiStyles.INK)
