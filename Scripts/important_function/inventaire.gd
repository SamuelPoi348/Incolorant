extends Control

@onready var pause_menu = $"../Pause"
@onready var colorux_label = $Colorux
@onready var vbox = $HBoxContainer/VBoxContainer

@onready var popup = $PopupDescription
@onready var popup_icon = popup.get_node("MarginContainer/VBoxContainer/IconLarge")
@onready var popup_label = popup.get_node("MarginContainer/VBoxContainer/DescriptionLabel")
@onready var popup_close_button = popup.get_node("MarginContainer/VBoxContainer/CloseButton")

# Table des items avec noms, textures et descriptions 
const ITEMS = {
	"rouge": {
		"name": "Icône Rouge",
		"texture": preload("res://Sprites/Icone_Rouge.png"),
		"description": "Cette icône Rouge vous permet de détruire certain bloc \n et de projeté une onde de choc avec la touche lancer projectile (default R)"
	},
	"jaune": {
		"name": "Icône Jaune",
		"texture": preload("res://Sprites/Icone_Jaune.png"),
		"description": "Cette icône Jaune vous permet de dépalcer certain bloc \n avec la touche intéraction spéciale (default T)"
	},
	"bleu": {
		"name": "Icône Bleu",
		"texture": preload("res://Sprites/Icone_Bleu.png"),
		"description": "Cette icône bleu vous permet de ralentir \n les projectile bleu (effet passif)"
	},
	"vert": {
		"name": "Icône Vert",
		"texture": preload("res://Sprites/Icone_Vert.png"),
		"description": "Cette icône vert vous permet de faire \n pousser et de rétrograder l'état d'une plante avec la touche \n (default T) pour changer de mode"
	}
}

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	popup.visible = false
	# popup_close_button.pressed.connect(Callable(self, "_on_close_button_pressed"))

func open_inventory():
	get_tree().paused = true
	update_colorux()
	update_inventory()
	visible = true

func close_inventory():
	get_tree().paused = false
	visible = false

func _input(event):
	if event.is_action_pressed("inventaire") and not pause_menu.visible:
		if visible:
			close_inventory()
		else:
			open_inventory()

func _on_button_pressed() -> void:
	close_inventory()

func update_colorux():
	var main = get_tree().root.get_node("Main")
	colorux_label.text = "x" + str(main.colorux)

func update_inventory():
	var main = get_tree().root.get_node("Main")
	
	# Vide le VBoxContainer avant de remplir
	for child in vbox.get_children():
		child.queue_free()
	
	# Ajoute uniquement les items débloqués
	for color_name in ITEMS.keys():
		if main.get("icone_" + color_name):
			_add_inventory_item(color_name)

func _add_inventory_item(color_name: String) -> void:
	var data = ITEMS[color_name]

	var hbox = HBoxContainer.new()

	var icon = TextureRect.new()
	icon.texture = data["texture"]
	icon.custom_minimum_size = Vector2(32, 32)
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	hbox.add_child(icon)

	var label = Label.new()
	label.text = data["name"]
	hbox.add_child(label)

	hbox.mouse_filter = Control.MOUSE_FILTER_PASS

	# ⚡ Correct pour Godot 4.6 : lambda pour passer color_name
	hbox.connect("gui_input", Callable(func(event):
		_on_item_gui_input_with_color(event, color_name)
	))

	vbox.add_child(hbox)

func _on_item_gui_input_with_color(event: InputEvent, color_name: String) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_show_description(color_name)

func _show_description(color_name: String) -> void:
	var data = ITEMS[color_name]
	popup_icon.texture = data["texture"]
	popup_label.text = data["description"]  # ✅ On utilise maintenant le champ description
	popup.popup_centered()

func _on_close_button_pressed() -> void:
	popup.hide()
