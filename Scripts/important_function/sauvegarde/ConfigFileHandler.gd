extends Node

var config = ConfigFile.new()
const SETTINGS_FILE_PATH = "user://setting.ini"

func _ready():
	if !FileAccess.file_exists(SETTINGS_FILE_PATH):
		_set_default_settings()
		config.save(SETTINGS_FILE_PATH)
	else:
		config.load(SETTINGS_FILE_PATH)

func _set_default_settings():
	config.set_value("keybinding","jump","W")
	config.set_value("keybinding","move_right","D")
	config.set_value("keybinding","move_left","A")
	config.set_value("keybinding","move_down","S")
	config.set_value("keybinding","shoot","R")
	config.set_value("keybinding","switch_incolorant_mode","T")
	config.set_value("keybinding","color_select","C")
	config.set_value("keybinding","pause","Escape")
	config.set_value("keybinding","interagir","E")
	config.set_value("keybinding","inventaire","Tab")

	config.set_value("video","fullscreen",false)

	config.set_value("audio","Master",1.0)
	config.set_value("audio","Music",1.0)
	config.set_value("audio","SFX",1.0)

	config.set_value("gameplay","auto_dialog",true)

func save_video_setting(key: String, value):
	config.set_value("video", key, value)
	var err = config.save(SETTINGS_FILE_PATH)
	if err != OK:
		push_warning("Failed to save video setting: %d" % err)

func load_video_setting():
	var video_settings = {}
	if config.has_section("video"):
		for key in config.get_section_keys("video"):
			video_settings[key] = config.get_value("video", key)
	return video_settings

func save_audio_setting(key: String, value):
	config.set_value("audio", key, value)
	var err = config.save(SETTINGS_FILE_PATH)
	if err != OK:
		push_warning("Failed to save audio setting: %d" % err)

func load_audio_setting():
	var audio_settings = {}
	if config.has_section("audio"):
		for key in config.get_section_keys("audio"):
			audio_settings[key] = config.get_value("audio", key)
	return audio_settings

func save_keybinding(action: StringName, event: InputEvent):
	var event_str
	if event is InputEventKey:
		event_str = _get_key_string(event)
	elif event is InputEventMouseButton:
		event_str = "mouse_" + str(event.button_index)
	else:
		return

	config.set_value("keybinding", action, event_str)
	var err = config.save(SETTINGS_FILE_PATH)
	if err != OK:
		push_warning("Failed to save keybinding: %d" % err)

func _get_key_string(event: InputEventKey) -> String:
	# Try physical_keycode first (cross-platform)
	if event.physical_keycode != KEY_NONE:
		var key_name = OS.get_keycode_string(event.physical_keycode)
		if key_name != "":
			return key_name
	# Fallback to keycode
	if event.keycode != KEY_NONE:
		var key_name = OS.get_keycode_string(event.keycode)
		if key_name != "":
			return key_name
	return "Unknown"

func load_keybindings():
	var keybindings = {}
	if !config.has_section("keybinding"):
		return keybindings

	var keys = config.get_section_keys("keybinding")
	for key in keys:
		var input_event
		var event_str = config.get_value("keybinding", key)

		if event_str is String and event_str.contains("mouse_"):
			input_event = InputEventMouseButton.new()
			input_event.button_index = int(event_str.split("_")[1])
		elif event_str is String:
			input_event = _create_key_event(event_str)
			if input_event == null:
				continue
		else:
			continue

		keybindings[key] = input_event
	return keybindings

func _create_key_event(event_str: String) -> InputEventKey:
	var input_event = InputEventKey.new()
	# Try to find the keycode from string
	var keycode = OS.find_keycode_from_string(event_str)
	if keycode != KEY_NONE:
		input_event.keycode = keycode
		input_event.physical_keycode = keycode
	else:
		# Try to parse common key names manually
		var mapped_key = _map_common_key(event_str)
		if mapped_key != KEY_NONE:
			input_event.keycode = mapped_key
			input_event.physical_keycode = mapped_key
		else:
			return null
	return input_event

func _map_common_key(key_name: String) -> Key:
	var upper = key_name.to_upper()
	match upper:
		"W": return KEY_W
		"A": return KEY_A
		"S": return KEY_S
		"D": return KEY_D
		"R": return KEY_R
		"T": return KEY_T
		"C": return KEY_C
		"ESCAPE": return KEY_ESCAPE
		"E": return KEY_E
		"TAB": return KEY_TAB
		"SPACE": return KEY_SPACE
		"SHIFT": return KEY_SHIFT
		"CONTROL": return KEY_CTRL
		"ALT": return KEY_ALT
		"ENTER": return KEY_ENTER
		"BACKSPACE": return KEY_BACKSPACE
		"UP": return KEY_UP
		"DOWN": return KEY_DOWN
		"LEFT": return KEY_LEFT
		"RIGHT": return KEY_RIGHT
		_: return KEY_NONE

func save_gameplay_setting(key: String, value):
	config.set_value("gameplay", key, value)
	var err = config.save(SETTINGS_FILE_PATH)
	if err != OK:
		push_warning("Failed to save gameplay setting: %d" % err)

func load_gameplay_setting():
	var gameplay_settings = {}
	if config.has_section("gameplay"):
		for key in config.get_section_keys("gameplay"):
			gameplay_settings[key] = config.get_value("gameplay", key)
	return gameplay_settings
