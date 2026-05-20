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

		var kb_raw = null
		var pad_raw = null

		if data.has(action):
			kb_raw = data[action].get("kb", null)
			pad_raw = data[action].get("pad", null)

		var kb_event = ConfigFileHandler._make_event(kb_raw, false)
		var pad_event = ConfigFileHandler._make_event(pad_raw, true)

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

	#InputMap.load_from_project_settings()
	#ConfigFileHandler.apply_keybindings()

	_rebuild_ui()

	print("Keybindings reset uniquement")
	
func _apply_rebind(action: String, type: String, event: InputEvent):
	# 0. retirer cette touche partout ailleurs
	ConfigFileHandler.remove_event_from_all_actions(event, action)
	await get_tree().process_frame

	# 1. supprimer ancien bind
	for e in InputMap.action_get_events(action):
		if type == "kb" and (e is InputEventKey or e is InputEventMouseButton):
			InputMap.action_erase_event(action, e)

		if type == "pad" and (e is InputEventJoypadButton or e is InputEventJoypadMotion):
			InputMap.action_erase_event(action, e)

	# 2. ajouter le nouveau bind
	InputMap.action_add_event(action, event)

	# 3. sauvegarde
	ConfigFileHandler.save_keybinding(action, event)

	# 4. UI refresh
	_update_single_row(action)

	# ⭐ IMPORTANT : stop le mode attente
	waiting_action = ""
	waiting_type = ""

	# reset visuel des boutons
	for row in action_list.get_children():
		row.set_waiting(false)
	
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
	
func has_event(action: String, event: InputEvent) -> bool:
	for e in InputMap.action_get_events(action):
		if e.as_text() == event.as_text():
			return true
	return false
