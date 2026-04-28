extends Control

@onready var pause_menu = $"../Pause"
@onready var colorux_label = $Colorux
@onready var vbox = $HBoxContainer/VBoxContainer
@onready var vbox2 = $HBoxContainer/VBoxContainer2
@onready var vbox3 = $HBoxContainer/VBoxContainer3

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

const SHOP_ITEMS = {
	"colorux_detector": {
		"name": "Colorux finder",
		"texture": preload("res://Sprites/object/colorux_object.png"),
		"description": "Vous permet de traquer le colorux le plus proche.\nVous pouvez aussi le désactiver."
	},
	
	"dash": {
		"name": "Flame exalté",
		"texture": preload("res://Sprites/object/dash_object.png"),
		"description": "Vous permet d'appuyer sur espace pour ensuite vous faire avancer à toute vitesse."
	},
	
	"double_saut": {
		"name": "Jump Jump fruit",
		"texture": preload("res://Sprites/object/jump_object.png"),
		"description": "Vous permet de faire un deuxième saut."
	},
	
	"teleporter_to_portail": {
		"name": "Livre TPTP",
		"texture": preload("res://Sprites/object/tptp_object.png"),
		"description": "Une téléportation vers un téléporteur si l'endroit a déjà été exploré auparavant (touche P)."
	},
	
	"golden_colorux": {
		"name": "Colorux doré",
		"texture": preload("res://Sprites/object/Golden_object.png"),
		"description": "Un cadeau du marchand… au moins l'odeur n'est pas mauvaise."
	}
}
const MANUSCRIPTS = {
	"manuscrit_rouge": {
		"name": "Manuscrit Rouge",
		"texture": preload("res://Sprites/M_Rouge.png"),
		"description": "Ce parchemin retrace les exploits des ancêtres rouges, toujours prêts à combattre et à affronter le danger."
		},
	"manuscrit_jaune": {
		"name": "Manuscrit Jaune",
		"texture": preload("res://Sprites/M_Jaune.png"),
		"description": "Ce parchemin raconte l’histoire des ancêtres jaunes, cherchant sans cesse à améliorer leur société et les conditions de vie de leur peuple."
		},
	"manuscrit_bleu": {
		"name": "Manuscrit Bleu",
		"texture": preload("res://Sprites/M_Bleu.png"),
		"description": "Ce parchemin retrace la vie du dernier chef bleu, connu pour son esprit observateur et son calme inébranlable."
		},
	"manuscrit_vert": {
		"name": "Manuscrit Vert",
		"texture": preload("res://Sprites/M_Vert.png"),
		"description": "Ce parchemin évoque les ancêtres verts, vivant en parfaite harmonie avec la nature et ses cycles."
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
	
	# 🔴 VIDE LES DEUX
	for child in vbox.get_children():
		child.queue_free()
	for child in vbox2.get_children():
		child.queue_free()
	for child in vbox3.get_children():
		child.queue_free()
	
	# 🎨 COULEURS (ancien système)
	for color_name in ITEMS.keys():
		if main.get("icone_" + color_name):
			_add_inventory_item(color_name, vbox, ITEMS)
	
	# 🛒 MARCHAND (nouveau système)
	for item_name in SHOP_ITEMS.keys():
		if main.get(item_name):
			_add_inventory_item(item_name, vbox2, SHOP_ITEMS)
			
	# 📜 MANUSCRITS (nouveau système)
	for item_name in MANUSCRIPTS.keys():
		if main.get(item_name):
			_add_inventory_item(item_name, vbox3, MANUSCRIPTS)

func _add_inventory_item(item_name: String, target_vbox: VBoxContainer, database: Dictionary) -> void:
	var data = database[item_name]

	var hbox = HBoxContainer.new()

	var icon = TextureRect.new()
	icon.texture = data["texture"]
	icon.custom_minimum_size = Vector2(32, 32)
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	hbox.add_child(icon)

	var label = Label.new()
	label.text = data["name"]
	hbox.add_child(label)
	
	if item_name == "colorux_detector":
		var cb = CheckButton.new()
		var main = get_tree().root.get_node("Main")
		cb.button_pressed = main.detector_ok
		cb.text = "Activer"
		cb.connect("toggled", Callable(func(button_pressed: bool):_on_detector_toggled(button_pressed, cb)))
		hbox.add_child(cb)
	
	hbox.mouse_filter = Control.MOUSE_FILTER_PASS

	hbox.connect("gui_input", Callable(func(event):
		_on_item_gui_input_with_data(event, data)
	))

	target_vbox.add_child(hbox)

func _on_item_gui_input_with_data(event: InputEvent, data: Dictionary) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		popup_icon.texture = data["texture"]
		popup_label.text = data["description"]
		popup.popup_centered()

func _show_description(color_name: String) -> void:
	var data = ITEMS[color_name]
	popup_icon.texture = data["texture"]
	popup_label.text = data["description"]  # ✅ On utilise maintenant le champ description
	popup.popup_centered()

func _on_close_button_pressed() -> void:
	popup.hide()
	
func _on_detector_toggled(button_pressed: bool, cb: CheckButton) -> void:
	var main = get_tree().root.get_node("Main")
	main.detector_ok = button_pressed
