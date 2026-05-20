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
func _on_remap_requested(action: String, type: String):
	waiting_action = action
	waiting_type = type

# =====================================================
# INPUT CAPTURE
# =====================================================
func _input(event):
	if waiting_action == "":
		return

	if not (event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton):
		return

	# 🔥 FILTER TYPE
	if waiting_type == "kb" and event is InputEventJoypadButton:
		return

	if waiting_type == "pad" and (event is InputEventKey or event is InputEventMouseButton):
		return

	# =================================================
	# REMOVE OLD BIND (same type only)
	# =================================================
	for e in InputMap.action_get_events(waiting_action):

		if waiting_type == "kb" and (e is InputEventKey or e is InputEventMouseButton):
			InputMap.action_erase_event(waiting_action, e)

		if waiting_type == "pad" and e is InputEventJoypadButton:
			InputMap.action_erase_event(waiting_action, e)

	# =================================================
	# ADD NEW EVENT
	# =================================================
	InputMap.action_add_event(waiting_action, event)

	# =================================================
	# SAVE (IMPORTANT)
	# =================================================
	ConfigFileHandler.save_keybinding(waiting_action, event)

	# 🔥 RELOAD INPUTMAP CLEANLY
	ConfigFileHandler.apply_keybindings()

	# =================================================
	# REFRESH UI
	# =================================================
	_rebuild_ui()

	waiting_action = ""
	waiting_type = ""

	accept_event()

# =====================================================
# RESET
# =====================================================
func _on_reset_button_pressed() -> void:
	InputMap.load_from_project_settings()
	ConfigFileHandler.apply_keybindings()
	_rebuild_ui()
