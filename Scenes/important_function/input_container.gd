extends HBoxContainer

signal remap_requested(action: String, type: String)

@onready var action_label = $LabelAction
@onready var kb_button = $KeyboardButton
@onready var pad_button = $GamepadButton

var action := ""

func setup(action_name: String, kb_event: InputEvent, pad_event: InputEvent):
	action = action_name
	action_label.text = action_name.capitalize()

	kb_button.text = _format_event(kb_event)
	pad_button.text = _format_event(pad_event)

func _format_event(event: InputEvent) -> String:
	if event == null:
		return "-"

	if event is InputEventKey:
		return OS.get_keycode_string(event.keycode)

	if event is InputEventMouseButton:
		return "Mouse " + str(event.button_index)

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

	return event.as_text()

func _on_keyboard_button_pressed():
	remap_requested.emit(action, "kb")

func _on_gamepad_button_pressed():
	remap_requested.emit(action, "pad")
