extends Node

var store: ProgressStore = ProgressStore.new()

func _ready() -> void:
	store.load_progress()

func complete_activity(concept_id: String) -> bool:
	return store.complete_activity(concept_id)
