extends Node

var config = ConfigFile.new()

func get_save_path(slot: int) -> String:
	return "user://save_%d.ini" % slot


func save_game(slot: int, data: Dictionary):
	var path = get_save_path(slot)

	config.clear()
	config.set_value("game", "data", data)

	var err = config.save(path)
	if err != OK:
		push_warning("Failed to save game to slot %d: %d" % [slot, err])


func load_game(slot: int) -> Dictionary:
	var path = get_save_path(slot)

	var err = config.load(path)

	if err != OK:
		return {}

	if config.has_section_key("game", "data"):
		return config.get_value("game", "data")

	return {}


func delete_save(slot: int):
	var path = get_save_path(slot)

	if FileAccess.file_exists(path):
		# Use DirAccess for cross-platform file deletion
		var dir = DirAccess.open("user://")
		if dir:
			var filename = path.replace("user://", "")
			dir.remove(filename)


func save_exists(slot: int) -> bool:
	return FileAccess.file_exists(get_save_path(slot))
