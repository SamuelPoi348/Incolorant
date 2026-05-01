extends Control
class_name ColorSelector

signal color_changed(new_color: String)

# ==========================
# Nodes
# ==========================
@onready var sprites := {
	"rouge": $"Root/Rouge",
	"jaune": $"Root/Jaune",
	"bleu": $"Root/Bleu",
	"vert": $"Root/Vert"
}
@onready var PowerUpSound = $PowerUpSound
# ==========================
# Variables
# ==========================
var couleur_active := ""

const SPACING := 64

const CROSS_POSITIONS := {
	"rouge": Vector2(SPACING, 0),
	"jaune": Vector2(SPACING * 2, SPACING),
	"bleu": Vector2(SPACING, SPACING * 2),
	"vert": Vector2(0, SPACING)
}
# ==========================
# READY
# ==========================
func _ready():
	PowerUpSound.bus = "SFX"
	#PowerUpSound.volume_db = -4
	visible = false
	
	# Positionnement des sprites
	for color_name in sprites.keys():
		sprites[color_name].position = CROSS_POSITIONS[color_name]
	
	update_visual()

# ==========================
# Input / Update
# ==========================
func _process(delta):
	var main = get_tree().root.get_node("Main")
	
	if main.color_locked:
		if main.selecting_color:
			main.set_selecting_color(false)
			hide_selector()
		return
		
	# 👇 NOUVEAU CHECK
	if not has_any_color_available():
		if main.selecting_color:
			main.set_selecting_color(false)
			hide_selector()
		return
	
	if Input.is_action_pressed("color_select"):
		#sound for input colorSelecting
		if not main.selecting_color:
			main.set_selecting_color(true)
			show_selector()
		handle_color_input()
	else:
		if main.selecting_color:
			main.set_selecting_color(false)
			hide_selector()

func handle_color_input():
	var main = get_tree().root.get_node("Main")
	
	if Input.is_action_just_pressed("ui_up") and main.icone_rouge:
		set_active_color("rouge")
	elif Input.is_action_just_pressed("ui_right") and main.icone_jaune:
		set_active_color("jaune")
	elif Input.is_action_just_pressed("ui_left") and main.icone_vert:
		set_active_color("vert")
	elif Input.is_action_just_pressed("ui_down") and main.icone_bleu:
		set_active_color("bleu")
	elif Input.is_action_just_pressed("base"):
		set_active_color("")

# ==========================
# Gestion couleur
# ==========================
func set_active_color(color_name: String):
	if couleur_active == color_name:
		return
	
	PowerUpSound.play()
	couleur_active = color_name
	update_visual()
	emit_signal("color_changed", couleur_active)
	
	var main = get_tree().root.get_node("Main")
	if main:
		main.set_color(couleur_active)
		
	print("Couleur active :", couleur_active)
	
	for player in get_tree().get_nodes_in_group("Player"):
		if player.has_method("update_color_from_manager"):
			player.update_color_from_manager(couleur_active)

# ==========================
# Affichage
# ==========================
func show_selector():
	visible = true
	update_visual()

func hide_selector():
	visible = false

func update_visual():
	var main = get_tree().root.get_node("Main")
	
	for color_name in sprites.keys():
		var sprite: Sprite2D = sprites[color_name]
		
		# Vérifie si l'icône est débloquée
		var enabled = main.get("icone_" + color_name)
		
		# 👇 Cache si non dispo
		sprite.visible = enabled
		
		if not enabled:
			continue
		
		# Texture ON / OFF
		if color_name == couleur_active:
			sprite.texture = load("res://Sprites/Selector/%s_on.png" % color_name)
		else:
			sprite.texture = load("res://Sprites/Selector/%s_off.png" % color_name)
		
func has_any_color_available() -> bool:
	var main = get_tree().root.get_node("Main")
	
	return (
		main.icone_rouge
		or main.icone_jaune
		or main.icone_bleu
		or main.icone_vert
	)
