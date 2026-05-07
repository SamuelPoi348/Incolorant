extends Node

var config = ConfigFile.new()

func get_save_path(slot: int) -> String:
	return "user://save_%d.ini" % slot


func save_game(slot: int, data: Dictionary):

	var path = get_save_path(slot)

	config.clear()

	config.set_value("game", "data", data)

	config.save(path)


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
		DirAccess.remove_absolute(path)


func save_exists(slot: int) -> bool:

	return FileAccess.file_exists(get_save_path(slot))
