extends Node

func world() -> void:
	AudioService.stop()
	get_tree().change_scene_to_file("res://scenes/World.tscn")
