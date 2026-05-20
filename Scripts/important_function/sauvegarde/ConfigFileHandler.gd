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
		"pad": {"type": "axis","axis": JOY_AXIS_TRIGGER_RIGHT,"value": 1}
	},

	"switch_incolorant_mode": {
		"kb": KEY_T,
		"pad": {"type": "axis","axis": JOY_AXIS_TRIGGER_LEFT,"value": 1}
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
			elif event is InputEventJoypadButton:
				keybindings[action]["pad"] = {
				"type": "button",
				"id": event.button_index}
			elif event is InputEventJoypadMotion:
				keybindings[action]["pad"] = {
				"type": "axis",
				"axis": event.axis,
				"value": event.axis_value}

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
	
func rebuild_all_inputmap():
	InputMap.load_from_project_settings()

	for action in config.get_value("keybinding", "data", {}):
		if InputMap.has_action(action):
			InputMap.action_erase_events(action)

			var kb = config.get_value("keybinding", "data")[action]["kb"]
			var pad = config.get_value("keybinding", "data")[action]["pad"]

			var kb_event = _make_event(kb, false)
			var pad_event = _make_event(pad, true)

			if kb_event:
				InputMap.action_add_event(action, kb_event)
			if pad_event:
				InputMap.action_add_event(action, pad_event)
				
func _clear_event_from_config(event: InputEvent):
	var data = config.get_value("keybinding", "data", {})

	for action in data.keys():

		var kb = data[action]["kb"]
		var pad = data[action]["pad"]

		# KEYBOARD / MOUSE
		if event is InputEventKey or event is InputEventMouseButton:

			var code: int

			if event is InputEventKey:
				code = event.keycode
			elif event is InputEventMouseButton:
				code = -event.button_index
			else:
				return

			if kb == code:
				data[action]["kb"] = null

		# GAMEPAD BUTTON
		elif event is InputEventJoypadButton:
			if pad is Dictionary and pad.get("type") == "button":
				if pad["id"] == event.button_index:
					data[action]["pad"] = null

		# GAMEPAD AXIS
		elif event is InputEventJoypadMotion:
			if pad is Dictionary and pad.get("type") == "axis":
				if pad["axis"] == event.axis and sign(pad["value"]) == sign(event.axis_value):
					data[action]["pad"] = null

	config.set_value("keybinding", "data", data)
	config.save(SETTINGS_FILE_PATH)
	
func swap_binding(new_event: InputEvent, target_action: String):

	var data = config.get_value("keybinding", "data", {})

	var new_code
	var new_pad = null

	if new_event is InputEventKey:
		new_code = new_event.keycode
	elif new_event is InputEventMouseButton:
		new_code = -new_event.button_index
	elif new_event is InputEventJoypadButton:
		new_pad = {"type": "button","id": new_event.button_index}
	elif new_event is InputEventJoypadMotion:
		new_pad = {"type": "axis","axis": new_event.axis,"value": new_event.axis_value}
	else:
		return

	var found_action := ""
	var old_value = null

	# 1. chercher si déjà utilisé
	for action in data.keys():

		var kb = data[action]["kb"]
		var pad = data[action]["pad"]

		if new_event is InputEventKey and kb == new_code:
			found_action = action
			break

		elif new_event is InputEventMouseButton and kb == new_code:
			found_action = action
			break

		elif new_event is InputEventJoypadButton and pad is Dictionary:
			if pad.get("type") == "button" and pad["id"] == new_event.button_index:
				found_action = action
				break

		elif new_event is InputEventJoypadMotion and pad is Dictionary:
			if pad.get("type") == "axis":
				if pad["axis"] == new_event.axis and sign(pad["value"]) == sign(new_event.axis_value):
					found_action = action
					break

	# 2. swap si trouvé
	if found_action != "" and found_action != target_action:

		# échange
		data[found_action]["kb"] = data[target_action]["kb"]
		data[target_action]["kb"] = new_code

	else:
		# simple assignation
		data[target_action]["kb"] = new_code

	config.set_value("keybinding", "data", data)
	config.save(SETTINGS_FILE_PATH)
	
func swap_pad_binding(event: InputEvent, target_action: String):

	var data = config.get_value("keybinding", "data", {})

	var new_pad = null

	if event is InputEventJoypadButton:
		new_pad = {"type":"button","id":event.button_index}

	elif event is InputEventJoypadMotion:
		new_pad = {
			"type":"axis",
			"axis":event.axis,
			"value":sign(event.axis_value)
		}

	var found_action := ""

	for action in data.keys():
		if action == target_action:
			continue

		var pad = data[action]["pad"]

		if pad is Dictionary:
			if new_pad["type"] == pad.get("type"):
				if new_pad["type"] == "button" and pad["id"] == new_pad["id"]:
					found_action = action
					break

				if new_pad["type"] == "axis" and pad["axis"] == new_pad["axis"]:
					found_action = action
					break

	if found_action != "" and found_action != target_action:
		data[found_action]["pad"] = data[target_action]["pad"]
		data[target_action]["pad"] = new_pad
	else:
		data[target_action]["pad"] = new_pad

	config.set_value("keybinding","data",data)
	config.save(SETTINGS_FILE_PATH)
