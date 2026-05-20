extends CharacterBody2D

const SPEED = 300.0

var current_dir = "none"
var couleur_active = ""
var movement_locked := false

# =========================
# INCOLORANT
# =========================

enum IncolorantMode { GROW, SHRINK }
var current_incolorant_mode := IncolorantMode.GROW

@onready var rayon_vert: Area2D = $RayonVert
@onready var rayon_sprite: AnimatedSprite2D = $RayonVert/RayonSprite

# =========================
# READY
# =========================

func _ready():
	$AnimatedSprite2D.play("front_idle")

	var main = get_tree().root.get_node("Main")
	couleur_active = main.couleur_active

	var color_selector = get_parent().get_node("CanvasLayer/ColorSelector")
	color_selector.color_changed.connect(Callable(self, "_on_color_changed"))

	rayon_vert.body_entered.connect(_on_rayon_body_entered)
	update_rayon_visual()

	add_to_group("Player")

# =========================
# COLOR SYSTEM
# =========================

func _on_color_changed(new_color: String):
	couleur_active = new_color

# =========================
# PHYSICS
# =========================

func _physics_process(delta: float) -> void:
	if movement_locked || Input.is_action_pressed("color_select"):
		return
	player_movement(delta)
	handle_color_powers()

# =========================
# MOVEMENT
# =========================

func player_movement(delta):

	if Input.is_action_pressed("move_right"):
		current_dir ="right"
		play_anim(1)
		velocity.x = SPEED
		velocity.y =0

	elif Input.is_action_pressed("move_left"):
		current_dir ="left"
		play_anim(1)
		velocity.x = -SPEED
		velocity.y =0

	elif Input.is_action_pressed("jump"):
		current_dir ="up"
		play_anim(1)
		velocity.x = 0
		velocity.y = -SPEED

	elif Input.is_action_pressed("move_down"):
		current_dir ="down"
		play_anim(1)
		velocity.x = 0
		velocity.y = SPEED

	else:
		play_anim(0)
		velocity = Vector2.ZERO

	move_and_slide()

# =========================
# COLOR POWERS
# =========================

func handle_color_powers():

	# ROUGE : tir
	if Input.is_action_just_pressed("shoot") and couleur_active == "rouge":
		lancer_projectile()

	# VERT : switch mode
	if Input.is_action_just_pressed("switch_incolorant_mode") and couleur_active == "vert":
		toggle_incolorant_mode()

	# JAUNE : activer plateformes
	if Input.is_action_just_pressed("switch_incolorant_mode") and couleur_active == "jaune":
		trigger_yellow_platforms()

	# Activer rayon vert
	if couleur_active == "vert":
		rayon_vert.monitoring = true
		rayon_sprite.visible = true
		appliquer_mode_aux_plantes_dans_zone()
	else:
		rayon_vert.monitoring = false
		rayon_sprite.visible = false

# =========================
# ROUGE SHOOT
# =========================

func lancer_projectile():

	var socles = get_tree().get_nodes_in_group("SocleRouge")
	var socle_plus_proche = null
	var distance_min = INF

	for socle in socles:
		var distance = global_position.distance_to(socle.global_position)
		if distance < distance_min:
			distance_min = distance
			socle_plus_proche = socle

	if socle_plus_proche and distance_min <= 20:
		var direction_shoot := Vector2.RIGHT if global_position.x < socle_plus_proche.global_position.x else Vector2.LEFT
		socle_plus_proche.lancer_sphere(direction_shoot)

# =========================
# INCOLORANT SYSTEM
# =========================

func toggle_incolorant_mode():

	current_incolorant_mode = IncolorantMode.SHRINK if current_incolorant_mode == IncolorantMode.GROW else IncolorantMode.GROW

	update_rayon_visual()
	appliquer_mode_aux_plantes_dans_zone()

func appliquer_mode_aux_plantes_dans_zone():

	for body in rayon_vert.get_overlapping_bodies():
		if body.is_in_group("Plante"):

			if current_incolorant_mode == IncolorantMode.GROW:
				body.grow()
			else:
				body.shrink()

func update_rayon_visual():

	if current_incolorant_mode == IncolorantMode.GROW:
		rayon_sprite.play("auraVert")
	else:
		rayon_sprite.play("reverseAuraVert")

func _on_rayon_body_entered(body):

	if couleur_active != "vert":
		return

	if body.is_in_group("Plante"):

		if current_incolorant_mode == IncolorantMode.GROW:
			body.grow()
		else:
			body.shrink()

# =========================
# JAUNE
# =========================

func trigger_yellow_platforms():

	for platform in get_tree().get_nodes_in_group("YellowPlatform"):
		platform.toggle()

# =========================
# ANIMATION
# =========================

func play_anim(movement):

	var anim = $AnimatedSprite2D
	var dir = current_dir

	var color_suffix = ""
	if couleur_active != "":
		color_suffix = "_" + couleur_active

	if dir == "right":
		anim.flip_h = false
		anim.play("side_walk" + color_suffix if movement == 1 else "side_idle" + color_suffix)

	elif dir == "left":
		anim.flip_h = true
		anim.play("side_walk" + color_suffix if movement == 1 else "side_idle" + color_suffix)

	elif dir == "up":
		anim.play("back_walk" if movement == 1 else "back_idle")

	elif dir == "down":
		anim.play("front_walk" + color_suffix if movement == 1 else "front_idle" + color_suffix)
