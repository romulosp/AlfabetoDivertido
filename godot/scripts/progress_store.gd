class_name ProgressStore
extends RefCounted

var data: Dictionary = {}
var path: String
var writable: bool = true

func _init(file_path: String = "user://progress.json") -> void:
	path = file_path

func defaults() -> Dictionary:
	return {"schemaVersion":2,"profileId":"local","completedActivities":[],"conceptProgress":{},"lastScene":"world","audioSettings":{"voice":0.8,"effects":0.6,"music":0.3,"ui":0.6},"accessibilitySettings":{"reducedMotion":false},"updatedAt":""}

func migrate(value: Dictionary) -> Dictionary:
	if not value.get("schemaVersion",0) is float and not value.get("schemaVersion",0) is int:
		return {}
	if int(value.get("schemaVersion", 0)) not in [1,2]:
		return {}
	if not value.get("completedActivities", []) is Array:
		return {}
	for concept: Variant in value.get("completedActivities",[]):
		if not concept is String or concept not in ["bola","casa","dado"]:
			return {}
	for field: String in ["conceptProgress","audioSettings","accessibilitySettings"]:
		if value.has(field) and not value[field] is Dictionary:
			return {}
	var migrated: Dictionary = defaults()
	migrated.merge(value, true)
	migrated.schemaVersion = 2
	var settings: Dictionary = defaults().audioSettings
	for channel: String in settings:
		var volume: Variant = value.get("audioSettings",{}).get(channel,settings[channel])
		if not volume is float and not volume is int:
			return {}
		settings[channel] = clampf(float(volume),0.0,1.0)
	migrated.audioSettings = settings
	return migrated

func read_valid(file_path: String) -> Dictionary:
	if not FileAccess.file_exists(file_path):
		return {}
	var parser: JSON = JSON.new()
	if parser.parse(FileAccess.get_file_as_string(file_path)) != OK:
		return {}
	var parsed: Variant = parser.data
	return migrate(parsed) if parsed is Dictionary else {}

func load_progress() -> bool:
	data = read_valid(path)
	if not data.is_empty():
		return true
	var backup: Dictionary = read_valid(path + ".bak")
	if not backup.is_empty():
		data = backup
		return true
	if FileAccess.file_exists(path) or FileAccess.file_exists(path + ".bak"):
		writable = false
		data = defaults()
		push_warning("Progresso inválido preservado; gravação bloqueada para evitar perda.")
		return false
	data = defaults()
	return true

func save() -> bool:
	if not writable:
		return false
	data.updatedAt = Time.get_datetime_string_from_system(true)
	var temporary: String = path + ".tmp"
	var file: FileAccess = FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(data))
	file.close()
	if read_valid(temporary).is_empty():
		return false
	if not read_valid(path).is_empty():
		if DirAccess.copy_absolute(path, path + ".bak") != OK:
			return false
	# Invalid primary is preserved separately before replacing with recovered data.
	elif FileAccess.file_exists(path):
		if DirAccess.copy_absolute(path, path + ".corrupt") != OK:
			return false
	return DirAccess.rename_absolute(temporary, path) == OK

func complete_activity(concept_id: String) -> bool:
	if concept_id not in ["bola","casa","dado"]:
		return false
	if concept_id not in data.completedActivities:
		data.completedActivities.append(concept_id)
	data.conceptProgress[concept_id] = {"completed":true}
	return save()

func reset_test_files() -> void:
	if not path.begins_with("user://test_"):
		return
	for suffix: String in ["", ".bak", ".tmp", ".corrupt"]:
		if FileAccess.file_exists(path + suffix):
			DirAccess.remove_absolute(path + suffix)
