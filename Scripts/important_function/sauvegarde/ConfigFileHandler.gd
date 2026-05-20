extends Node

var config := ConfigFile.new()
const SETTINGS_FILE_PATH := "user://setting.ini"

const DEFAULT_KEYBINDS = {
	"base": {
		"kb": KEY_X,
		"pad": {"type": "button", "id": JOY_BUTTON_LEFT_SHOULDER}
	},

	"color_select": {
		"kb": KEY_C,
		"pad": {"type": "button", "id": JOY_BUTTON_Y}
	},

	"jump": {
		"kb": KEY_W,
		"pad": {"type": "axis", "axis": JOY_AXIS_LEFT_Y, "value": -1}
	},

	"move_right": {
		"kb": KEY_D,
		"pad": {"type": "axis", "axis": JOY_AXIS_LEFT_X, "value": 1}
	},

	"move_left": {
		"kb": KEY_A,
		"pad": {"type": "axis", "axis": JOY_AXIS_LEFT_X, "value": -1}
	},

	"move_down": {
		"kb": KEY_S,
		"pad": {"type": "axis", "axis": JOY_AXIS_LEFT_Y, "value": 1}
	},

	"shoot": {
		"kb": KEY_R,
		"pad": {"type": "button", "id": JOY_AXIS_TRIGGER_RIGHT}
	},

	"switch_incolorant_mode": {
		"kb": KEY_T,
		"pad": {"type": "button", "id": JOY_AXIS_TRIGGER_LEFT}
	},

	"dash": {
		"kb": KEY_SPACE,
		"pad": {"type": "button", "id": JOY_BUTTON_B}
	},

	"interagir": {
		"kb": KEY_E,
		"pad": {"type": "button", "id": JOY_BUTTON_X}
	},

	"inventaire": {
		"kb": KEY_TAB,
		"pad": {"type": "button", "id": JOY_BUTTON_START}
	},

	"pause": {
		"kb": KEY_ESCAPE,
		"pad": {"type": "button", "id": JOY_BUTTON_BACK}
	},

	"tp": {
		"kb": KEY_P,
		"pad": {"type": "button", "id": JOY_BUTTON_RIGHT_SHOULDER}
	}
}
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
			if event is InputEventKey:
				keybindings[action]["kb"] = event.keycode
			elif event is InputEventMouseButton:
				keybindings[action]["kb"] = -event.button_index
			elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
				keybindings[action]["pad"] = event

	config.set_value("keybinding", "data", keybindings)
	reset_keybindings()
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

	if event is InputEventKey:
		data[action]["kb"] = event.keycode

	elif event is InputEventMouseButton:
		data[action]["kb"] = -event.button_index  # option mouse safe

	elif event is InputEventJoypadButton:
		data[action]["pad"] = {
			"type": "button",
			"id": event.button_index
		}

	elif event is InputEventJoypadMotion:
		data[action]["pad"] = {
			"type": "axis",
			"axis": event.axis,
			"value": event.axis_value
		}

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

	var data = config.get_value("keybinding", "data", {})

	if typeof(data) != TYPE_DICTIONARY:
		return

	for action in data.keys():

		if not InputMap.has_action(action):
			continue

		InputMap.action_erase_events(action)

		var kb = data[action]["kb"]
		var pad = data[action]["pad"]

		var kb_event = _make_event(kb, false)
		var pad_event = _make_event(pad, true)

		if kb_event:
			InputMap.action_add_event(action, kb_event)

		if pad_event:
			InputMap.action_add_event(action, pad_event)

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
	var data := {}

	for action in DEFAULT_KEYBINDS.keys():
		data[action] = {
			"kb": DEFAULT_KEYBINDS[action]["kb"],
			"pad": DEFAULT_KEYBINDS[action]["pad"]
		}

	config.set_value("keybinding", "data", data)
	config.save(SETTINGS_FILE_PATH)

	apply_keybindings()
	
func _make_event(data, is_pad: bool) -> InputEvent:
	if data == null:
		return null

	# ======================
	# KEYBOARD / MOUSE
	# ======================
	if not is_pad:

		if typeof(data) != TYPE_INT:
			return null

		# mouse
		if data < 0:
			var e := InputEventMouseButton.new()
			e.button_index = -data
			return e

		# keyboard
		var e := InputEventKey.new()
		e.keycode = data
		return e

	# ======================
	# GAMEPAD
	# ======================
	if typeof(data) != TYPE_DICTIONARY:
		return null

	if data.get("type") == "button":
		var e := InputEventJoypadButton.new()
		e.button_index = data["id"]
		return e

	if data.get("type") == "axis":
		var e := InputEventJoypadMotion.new()
		e.axis = data["axis"]
		e.axis_value = data["value"]
		return e

	return null
	
func kb_to_event(code: int) -> InputEventKey:
	var e := InputEventKey.new()
	e.keycode = abs(code) # important pour mouse négatif
	return e


func is_mouse_code(code: int) -> bool:
	return code < 0
	
func pad_to_event(data: Dictionary):
	if data.type == "button":
		var e := InputEventJoypadButton.new()
		e.button_index = data.id
		return e

	if data.type == "axis":
		var e := InputEventJoypadMotion.new()
		e.axis = data.axis
		e.axis_value = data.value
		return e

func has_event(action: String, event: InputEvent) -> bool:
	for e in InputMap.action_get_events(action):
		if e.as_text() == event.as_text():
			return true
	return false
	
func remove_event_from_all_actions(event: InputEvent, except_action: String = ""):
	for action in InputMap.get_actions():

		if action.begins_with("ui_"):
			continue

		if action == except_action:
			continue

		var events = InputMap.action_get_events(action).duplicate()

		for e in events:

			var is_same := false

			if event is InputEventKey and e is InputEventKey:
				is_same = event.keycode == e.keycode

			elif event is InputEventMouseButton and e is InputEventMouseButton:
				is_same = event.button_index == e.button_index

			elif event is InputEventJoypadButton and e is InputEventJoypadButton:
				is_same = event.button_index == e.button_index

			elif event is InputEventJoypadMotion and e is InputEventJoypadMotion:
				is_same = event.axis == e.axis and sign(event.axis_value) == sign(e.axis_value)

			if is_same:
				print("SUPPRIMÉ:", action)
				InputMap.action_erase_event(action, e)
