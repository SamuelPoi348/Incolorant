extends Button

signal remap_requested(action: String, type: String)

var action := ""

var action_label
var kb_label
var pad_label
var is_waiting := false

func set_waiting(value: bool):
	if value:
		kb_label.text = "Attente de touche..."
		pad_label.text = ""
		modulate = Color(1, 0.8, 0.3)
	else:
		modulate = Color.WHITE

func _ready():
	action_label = $MarginContainer/HBoxContainer/LabelAction
	kb_label = $MarginContainer/HBoxContainer/HBoxContainer/KeyboardButton
	pad_label = $MarginContainer/HBoxContainer/HBoxContainer/GamepadButton
	
	pressed.connect(_on_pressed)
	
func _on_pressed():
	remap_requested.emit(action)
	
func setup(action_name: String, kb_event: InputEvent, pad_event: InputEvent):
	action = action_name

	# attendre que _ready soit fait
	if action_label == null:
		await ready

	action_label.text = action_name.capitalize()
	kb_label.text = _format_event(kb_event)
	pad_label.text = _format_event(pad_event)

func _format_event(event: InputEvent) -> String:
	if event == null:
		return "-"

	# =========================
	# KEYBOARD
	# =========================
	if event is InputEventKey:
		return OS.get_keycode_string(event.keycode)

	# =========================
	# MOUSE
	# =========================
	if event is InputEventMouseButton:
		return "Mouse " + str(event.button_index)

	# =========================
	# JOYPAD BUTTON
	# =========================
	if event is InputEventJoypadButton:
		match event.button_index:
			JOY_BUTTON_A: return "A"
			JOY_BUTTON_B: return "B"
			JOY_BUTTON_X: return "X"
			JOY_BUTTON_Y: return "Y"
			JOY_BUTTON_LEFT_SHOULDER: return "LB"
			JOY_BUTTON_RIGHT_SHOULDER: return "RB"
			JOY_BUTTON_LEFT_STICK: return "LS"
			JOY_BUTTON_RIGHT_STICK: return "RS"
			_: return "Pad " + str(event.button_index)

	# =========================
	# JOYPAD MOTION (AXIS) FIX
	# =========================
	if event is InputEventJoypadMotion:

		var motion := event as InputEventJoypadMotion
		if motion == null:
			return event.as_text()

		var axis := motion.axis
		var value := motion.axis_value

		var axis_name := ""

		match axis:
			JOY_AXIS_LEFT_X:
				axis_name = "Left Stick X"
			JOY_AXIS_LEFT_Y:
				axis_name = "Left Stick Y"
			JOY_AXIS_RIGHT_X:
				axis_name = "Right Stick X"
			JOY_AXIS_RIGHT_Y:
				axis_name = "Right Stick Y"
			JOY_AXIS_TRIGGER_LEFT:
				axis_name = "LT"
			JOY_AXIS_TRIGGER_RIGHT:
				axis_name = "RT"
			_:
				axis_name = "Axis " + str(axis)

		# direction lisible
		var direction := ""
		if value < 0:
			direction = "-"
		else:
			direction = "+"

		return axis_name + " " + direction + str(abs(value))

	# =========================
	# FALLBACK
	# =========================
	return event.as_text()

	
