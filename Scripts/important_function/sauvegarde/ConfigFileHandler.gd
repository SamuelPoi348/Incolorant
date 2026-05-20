extends Node

var config := ConfigFile.new()
const SETTINGS_FILE_PATH := "user://setting.ini"

# =====================================================
# INIT
# =====================================================
func _ready():
	if !FileAccess.file_exists(SETTINGS_FILE_PATH):
		_set_default_settings()
		config.save(SETTINGS_FILE_PATH)
	else:
		config.load(SETTINGS_FILE_PATH)

# =====================================================
# DEFAULT SETTINGS
# =====================================================
func _set_default_settings():

	var keybindings := {}

	for action in InputMap.get_actions():
		if action.begins_with("ui_"):
			continue

		keybindings[action] = {
			"kb": null,
			"pad": null
		}

		for event in InputMap.action_get_events(action):
			if event is InputEventKey or event is InputEventMouseButton:
				keybindings[action]["kb"] = event
			elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
				keybindings[action]["pad"] = event

	config.set_value("keybinding", "data", keybindings)

	# VIDEO
	config.set_value("video", "fullscreen", false)

	# AUDIO
	config.set_value("audio", "Master", 1.0)
	config.set_value("audio", "Music", 1.0)
	config.set_value("audio", "SFX", 1.0)

	# GAMEPLAY
	config.set_value("gameplay", "auto_dialog", true)

# =====================================================
# KEYBINDING SAVE
# =====================================================
func save_keybinding(action: String, event: InputEvent):

	var data = config.get_value("keybinding", "data", {})

	if typeof(data) != TYPE_DICTIONARY:
		data = {}

	if not data.has(action):
		data[action] = {"kb": null, "pad": null}

	if event is InputEventKey or event is InputEventMouseButton:
		data[action]["kb"] = event

	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		data[action]["pad"] = event

	config.set_value("keybinding", "data", data)
	config.save(SETTINGS_FILE_PATH)

# =====================================================
# KEYBINDING LOAD
# =====================================================
func load_keybindings() -> Dictionary:
	var result := {}

	var data = config.get_value("keybinding", "data", {})

	if typeof(data) != TYPE_DICTIONARY:
		return result

	for action in data.keys():

		var entry = data[action]
		if typeof(entry) != TYPE_DICTIONARY:
			continue

		result[action] = {
			"kb": entry.get("kb", null),
			"pad": entry.get("pad", null)
		}

	return result

# =====================================================
# APPLY INPUTMAP
# =====================================================
func apply_keybindings():
	
	InputMap.load_from_project_settings()
	var data = load_keybindings()

	for action in data.keys():

		if not InputMap.has_action(action):
			continue

		InputMap.action_erase_events(action)

		var kb = data[action]["kb"]
		var pad = data[action]["pad"]

		if kb:
			InputMap.action_add_event(action, kb)

		if pad:
			InputMap.action_add_event(action, pad)

# =====================================================
# VIDEO SETTINGS
# =====================================================
func save_video_setting(key: String, value):
	config.set_value("video", key, value)
	config.save(SETTINGS_FILE_PATH)

func load_video_setting():
	var video_settings := {}

	if config.has_section("video"):
		for key in config.get_section_keys("video"):
			video_settings[key] = config.get_value("video", key)

	return video_settings

# =====================================================
# AUDIO SETTINGS
# =====================================================
func save_audio_setting(key: String, value):
	config.set_value("audio", key, value)
	config.save(SETTINGS_FILE_PATH)

func load_audio_setting():
	var audio_settings := {}

	if config.has_section("audio"):
		for key in config.get_section_keys("audio"):
			audio_settings[key] = config.get_value("audio", key)

	return audio_settings

# =====================================================
# GAMEPLAY SETTINGS
# =====================================================
func save_gameplay_setting(key: String, value):
	config.set_value("gameplay", key, value)
	config.save(SETTINGS_FILE_PATH)

func load_gameplay_setting():
	var gameplay_settings := {}

	if config.has_section("gameplay"):
		for key in config.get_section_keys("gameplay"):
			gameplay_settings[key] = config.get_value("gameplay", key)

	return gameplay_settings
	
# =====================================================
# RESET SETTINGS
# =====================================================
func reset_settings():

	# reset mémoire
	config = ConfigFile.new()

	# supprimer ancien fichier
	if FileAccess.file_exists(SETTINGS_FILE_PATH):
		DirAccess.remove_absolute(SETTINGS_FILE_PATH)

	# remettre valeurs par défaut
	_set_default_settings()

	# sauvegarder nouveau fichier
	config.save(SETTINGS_FILE_PATH)

	# réappliquer les inputs
	apply_keybindings()

func reset_keybindings():

	# reset config en mémoire
	var data = {}

	# reconstruire uniquement les defaults
	for action in InputMap.get_actions():
		if action.begins_with("ui_"):
			continue

		data[action] = {
			"kb": null,
			"pad": null
		}

		for event in InputMap.action_get_events(action):
			if event is InputEventKey or event is InputEventMouseButton:
				data[action]["kb"] = event
			elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
				data[action]["pad"] = event

	config.set_value("keybinding", "data", data)
	config.save(SETTINGS_FILE_PATH)

	apply_keybindings()
