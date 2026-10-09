extends Node

var concepts: Array[Dictionary] = []

func _ready() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://content/catalog_runtime.json"))
	if parsed is Dictionary:
		for entry: Dictionary in parsed.get("concepts", []):
			if entry.get("conceptId", "") in ["bola","casa","dado"]:
				concepts.append(entry)

func get_concept(concept_id: String) -> Dictionary:
	for concept: Dictionary in concepts:
		if concept.conceptId == concept_id:
			return concept
	return {}
