extends Node

var config = ConfigFile.new()
const SAVE_FILE_PATH = "user://save.ini"

func save_game(data: Dictionary):
	config.set_value("game", "data", data)
	config.save(SAVE_FILE_PATH)

func load_game() -> Dictionary:
	var err = config.load(SAVE_FILE_PATH)
	if err != OK:
		return {}
	
	if config.has_section_key("game", "data"):
		return config.get_value("game", "data")
	
	return {}
	
func delete_save():
	if FileAccess.file_exists(SAVE_FILE_PATH):
		DirAccess.remove_absolute(SAVE_FILE_PATH)
