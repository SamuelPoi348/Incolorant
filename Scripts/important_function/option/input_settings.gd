extends Control

@onready var input_row_scene = preload("res://Scenes/important_function/input_button.tscn")
@onready var action_list = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ActionList

var waiting_action := ""
var waiting_type := "" # "kb" ou "pad"

var input_actions = {
	"jump": "sauter",
	"move_right": "bouger vers la droite",
	"move_left": "bouger vers la gauche",
	"move_down": "bouger vers le bas",
	"shoot": "lancer projectile",
	"switch_incolorant_mode": "interaction spéciale",
	"color_select": "changement de couleur",
	"interagir": "interagir",
	"inventaire": "inventaire",
	"base": "suppression de couleur",
	"dash": "dash",
	"tp": "téléporter"
}

# =====================================================
# INIT
# =====================================================
func _ready():
	ConfigFileHandler.apply_keybindings()
	_rebuild_ui()

# =====================================================
# BUILD UI
# =====================================================
func _rebuild_ui():

	for c in action_list.get_children():
		c.queue_free()

	var data = ConfigFileHandler.load_keybindings()

	for action in input_actions.keys():

		var row = input_row_scene.instantiate()

		var kb_event = null
		var pad_event = null

		if data.has(action):
			kb_event = data[action]["kb"]
			pad_event = data[action]["pad"]

		row.setup(action, kb_event, pad_event)

		row.remap_requested.connect(_on_remap_requested)

		action_list.add_child(row)

# =====================================================
# REMAP START
# =====================================================
func _on_remap_requested(action: String):
	waiting_action = action

	for row in action_list.get_children():
		row.set_waiting(row.action == action)

# =====================================================
# INPUT CAPTURE
# =====================================================
func _input(event):
	if waiting_action == "":
		return

	if not (event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton):
		return

	# filtre type attendu
	if waiting_type == "kb" and _is_gamepad(event):
		return

	if waiting_type == "pad" and _is_keyboard_or_mouse(event):
		return

	_apply_rebind(waiting_action, waiting_type, event)

# =====================================================
# RESET
# =====================================================
func _on_reset_button_pressed() -> void:

	ConfigFileHandler.reset_keybindings()

	waiting_action = ""
	waiting_type = ""

	InputMap.load_from_project_settings()
	ConfigFileHandler.apply_keybindings()

	_rebuild_ui()

	print("Keybindings reset uniquement")
	
func _apply_rebind(action: String, type: String, event: InputEvent):

	# 1. remove old bind
	for e in InputMap.action_get_events(action):

		if type == "kb" and _is_keyboard_or_mouse(e):
			InputMap.action_erase_event(action, e)

		if type == "pad" and _is_gamepad(e):
			InputMap.action_erase_event(action, e)

	# 2. add new
	InputMap.action_add_event(action, event)

	# 3. save
	ConfigFileHandler.save_keybinding(action, event)

	# 4. update ONLY UI row (pas rebuild)
	_update_single_row(action)

	for row in action_list.get_children():
		row.set_waiting(false)
		
	waiting_action = ""
	waiting_type = ""
	accept_event()
	
func _update_single_row(action: String):
	for row in action_list.get_children():
		if row.action == action:
			var kb = null
			var pad = null

			for e in InputMap.action_get_events(action):
				if e is InputEventKey or e is InputEventMouseButton:
					kb = e
				elif e is InputEventJoypadButton or e is InputEventJoypadMotion:
					pad = e

			row.setup(action, kb, pad)
			break

func _is_keyboard_or_mouse(event: InputEvent) -> bool:
	return event is InputEventKey or event is InputEventMouseButton

func _is_gamepad(event: InputEvent) -> bool:
	return event is InputEventJoypadButton or event is InputEventJoypadMotion
