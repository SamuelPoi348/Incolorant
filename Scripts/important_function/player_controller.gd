extends CharacterBody2D
class_name PlayerController

@onready var animation_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var color_selector = $"../../CanvasLayer/ColorSelector"
@onready var detecteur: Node2D = $Détecteur
@onready var dieSound = $DieSound
@onready var dashSound = $DashSound
@onready var jumpSound = $JumpSound
@onready var tpSound = $TPSound
@onready var csmSound = $ColorSpecialModeSound

@export var speed: float = 10.0
@export var jump_power: float = 10.0

var main 

var speed_multiplier: float = 30.0
var jump_multiplier: float = -30.0
var direction: float = 0.0

var main_sm: LimboHSM
var shoot_frame_triggered := false

var double_saut_ok=true
var dash_ok=true
var portal
signal color_changed(new_color: String)

# ==============================
# COULEURS
# ==============================

var couleur_active: String = ""

# ==============================
# INCOLORANT
# ==============================

enum IncolorantMode { GROW, SHRINK }
var current_incolorant_mode := IncolorantMode.GROW

@onready var rayon_vert: Area2D = $RayonVert
@onready var rayon_sprite: AnimatedSprite2D = $RayonVert/RayonSprite

@export var death_y_limit: float = -20
var is_dead := false
var tp_ok
# =====================================================
# READY
# =====================================================

func _ready():
	_load_keybindings_from_settings()
	initiate_state_machine()
	animation_sprite.animation_finished.connect(_on_animation_finished)
	animation_sprite.frame_changed.connect(_on_frame_changed)
	rayon_vert.body_entered.connect(_on_rayon_body_entered)

	rayon_sprite.z_index = -1
	update_rayon_visual()
	main = get_tree().root.get_node("Main")
	add_to_group("Player")
	portal = get_tree().get_first_node_in_group("portail")
	tp_ok = main.scene_courante in main.niveaux_completes
	# Connection au signal de changement de couleur
	color_selector.color_changed.connect(Callable(self, "_on_color_changed"))
	detecteur.visible = main.detector_ok
	dieSound.bus = "SFX"
	dashSound.bus = "SFX"
	jumpSound.bus = "SFX"
	tpSound.bus = "SFX"
	csmSound.bus = "SFX"
	
func _load_keybindings_from_settings():
	var keybindings = ConfigFileHandler.load_keybindings()
	for action in keybindings.keys():
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action,keybindings[action])

func _process(delta):
	main = get_tree().root.get_node("Main")
	
	# Mise à jour visibilité du détecteur selon presence de Colorux
	var closest_colorux = find_closest_colorux()
	detecteur.visible = main.detector_ok and closest_colorux != null
	
	# Positionner le détecteur devant le joueur et orienter vers le colorux
	if detecteur.visible:
		update_detecteur_position(closest_colorux)
	
	# Ton code existant
	if main.double_saut ==  false:
		double_saut_ok=false
	if main.dash == false:
		dash_ok=false
	pass

# =====================================================
# Gestion couleur depuis ColorSelector
# =====================================================

func _on_color_changed(new_color: String):
	update_color_from_manager(new_color)

# Appelée depuis ColorSelector
func update_color_from_manager(new_color: String):
	couleur_active = new_color
	play_animation_with_color("idle")

# =====================================================
# PHYSICS
# =====================================================

func _physics_process(delta: float) -> void:
	
	# Bloque le joueur pendant sélection couleur
	if get_tree().root.get_node("Main").selecting_color:
		return
	if Input.is_action_just_pressed("tp") and main.teleporter_to_portail and tp_ok:
		tp_to_portal()
	if is_dashing:
		move_and_slide()
		
	if not is_on_floor():
		if Input.is_action_just_pressed("jump") and double_saut_ok:
			jumpSound.play()
			velocity.y = jump_power * jump_multiplier
			main_sm.dispatch(&"to_jump")
			double_saut_ok=false
		#if not is_dashing:
		velocity += get_gravity() * delta

	direction = Input.get_axis("move_left", "move_right")

	if direction != 0:
		velocity.x = direction * speed * speed_multiplier
	else:
		velocity.x = move_toward(velocity.x, 0, speed * speed_multiplier)

	if Input.is_action_just_pressed("jump") and is_on_floor():
		jumpSound.play()
		velocity.y = jump_power * jump_multiplier
		main_sm.dispatch(&"to_jump")

	if Input.is_action_just_pressed("dash") and dash_ok and animation_sprite.animation != "dash":
		dashSound.play()
		dash_ok=false
		main_sm.dispatch(&"to_dash")
		var dash_direction = direction
	
		# Si le joueur n'appuie sur rien → dash dans la direction du sprite
		if dash_direction == 0:
			dash_direction = -1 if animation_sprite.flip_h else 1
	
		velocity.x = dash_direction * 600  # puissance du dash
		velocity.y = 0  # optionnel : annule la chute pendant le dash
		
		
	if is_on_floor():
		dash_ok=true
		double_saut_ok=true
	
	if Input.is_action_just_pressed("shoot") and couleur_active == "rouge":
		main_sm.dispatch(&"to_shoot")

	if Input.is_action_just_pressed("switch_incolorant_mode") and couleur_active == "vert":
		csmSound.play()
		toggle_incolorant_mode()

	if Input.is_action_just_pressed("switch_incolorant_mode") and couleur_active == "jaune":
		csmSound.play()
		trigger_yellow_platforms()

	if couleur_active == "vert":
		rayon_vert.monitoring = true
		appliquer_mode_aux_plantes_dans_zone()
		rayon_sprite.visible = true
	else:
		rayon_vert.monitoring = false
		rayon_sprite.visible = false

	flip_sprite(direction)
	move_and_slide()
	check_red_block_collision()
	check_death()

func check_death():
	if is_dead:
		return
		
	if global_position.y > death_y_limit:
		die()

func die():
	is_dead = true
	dieSound.play()
	velocity = Vector2.ZERO
	set_physics_process(false)
	await dieSound.finished
	var death_ui = get_tree().get_first_node_in_group("DeathUI")
	if death_ui:
		death_ui.visible = true
	# 🔥 IMPORTANT : désactiver les autres UI
	get_node("../../CanvasLayer/ColorSelector").visible = false
	#get_node("../../CanvasLayer/Pause").visible = false
	#get_node("../../CanvasLayer/Inventaire").visible = false
	#Engine.time_scale = 0.0
	

# =====================================================
# ANIMATION CALLBACKS
# =====================================================

func _on_animation_finished():
	if animation_sprite.animation == "shoot":
		main_sm.dispatch(&"state_ended")

func _on_frame_changed():
	if animation_sprite.animation == "shoot":
		if animation_sprite.frame == 2 and not shoot_frame_triggered:
			shoot_frame_triggered = true
			lancer_projectile()

# =====================================================
# STATE MACHINE
# =====================================================

func initiate_state_machine():
	main_sm = LimboHSM.new()
	add_child(main_sm)

	var idle_state = LimboState.new().named("idle").call_on_enter(idle_start).call_on_update(idle_update)
	var walk_state = LimboState.new().named("walk").call_on_enter(walk_start).call_on_update(walk_update)
	var jump_state = LimboState.new().named("jump").call_on_enter(jump_start).call_on_update(jump_update)
	var attack_state = LimboState.new().named("attack").call_on_enter(attack_start).call_on_update(attack_update)
	var shoot_state = LimboState.new().named("shoot").call_on_enter(shoot_start).call_on_update(shoot_update)
	var dash_state = LimboState.new().named("dash").call_on_enter(dash_start).call_on_update(dash_update)
	
	main_sm.add_child(dash_state)
	
	main_sm.add_child(idle_state)
	main_sm.add_child(walk_state)
	main_sm.add_child(jump_state)
	main_sm.add_child(attack_state)
	main_sm.add_child(shoot_state)

	main_sm.initial_state = idle_state

	main_sm.add_transition(idle_state, walk_state, &"to_walk")
	main_sm.add_transition(walk_state, idle_state, &"state_ended")

	main_sm.add_transition(idle_state, jump_state, &"to_jump")
	main_sm.add_transition(walk_state, jump_state, &"to_jump")

	main_sm.add_transition(main_sm.ANYSTATE, attack_state, &"to_attack")

	main_sm.add_transition(jump_state, idle_state, &"state_ended")

	main_sm.add_transition(main_sm.ANYSTATE, shoot_state, &"to_shoot")
	main_sm.add_transition(shoot_state, idle_state, &"state_ended")

	main_sm.add_transition(main_sm.ANYSTATE, dash_state, &"to_dash")
	main_sm.add_transition(dash_state, idle_state, &"state_ended")

	main_sm.initialize(self)
	main_sm.set_active(true)

# =====================================================
# ETATS (idle, walk, jump, attack, shoot)
# =====================================================

func idle_start(): play_animation_with_color("idle")
func idle_update(delta: float):
	if not is_on_floor(): main_sm.dispatch(&"to_jump")
	elif velocity.x != 0: main_sm.dispatch(&"to_walk")

func walk_start(): play_animation_with_color("move")
func walk_update(delta: float):
	if not is_on_floor(): main_sm.dispatch(&"to_jump")
	elif velocity.x == 0: main_sm.dispatch(&"state_ended")

func jump_start(): play_animation_with_color("jump")
func jump_update(delta: float):
	if velocity.y > 0: play_animation_with_color("fall")
	if is_on_floor(): main_sm.dispatch(&"state_ended")

func attack_start(): animation_sprite.play("attack")
func attack_update(delta: float): pass

func shoot_start():
	animation_sprite.play("shoot")
	velocity.x = 0
	shoot_frame_triggered = false
func shoot_update(delta: float): pass

var is_dashing = false
var dash_timer = 0.0

func dash_start():
	is_dashing = true
	dash_timer = 0.8
	animation_sprite.play("dash")

func dash_update(delta: float):
	dash_timer -= delta
	
	if dash_timer <= 0:
		is_dashing = false
		main_sm.dispatch(&"state_ended")
# =====================================================
# SHOOT LOGIC
# =====================================================

func lancer_projectile():
	var socles = get_tree().get_nodes_in_group("SocleRouge")
	var socle_plus_proche = null
	var distance_min = INF
	for socle in socles:
		var distance = global_position.distance_to(socle.global_position)
		if distance < distance_min:
			distance_min = distance
			socle_plus_proche = socle

	if socle_plus_proche and distance_min <= 24:
		var direction_shoot := Vector2.RIGHT if global_position.x < socle_plus_proche.global_position.x else Vector2.LEFT
		socle_plus_proche.lancer_sphere(direction_shoot)

# =====================================================
# INCOLORANT SYSTEM
# =====================================================

func toggle_incolorant_mode():
	current_incolorant_mode = IncolorantMode.SHRINK if current_incolorant_mode == IncolorantMode.GROW else IncolorantMode.GROW
	update_rayon_visual()
	appliquer_mode_aux_plantes_dans_zone()

func appliquer_mode_aux_plantes_dans_zone():
	for body in rayon_vert.get_overlapping_bodies():
		if body.is_in_group("Plante"):
			if current_incolorant_mode == IncolorantMode.GROW: body.grow()
			else: body.shrink()

func update_rayon_visual():
	if current_incolorant_mode == IncolorantMode.GROW: rayon_sprite.play("auraVert")
	else: rayon_sprite.play("reverseAuraVert")

func _on_rayon_body_entered(body):
	if couleur_active != "vert": return
	if body.is_in_group("Plante"):
		if current_incolorant_mode == IncolorantMode.GROW: body.grow()
		else: body.shrink()

func flip_sprite(dir: float):
	
	if dir > 0:
		animation_sprite.flip_h = false
	elif dir < 0:
		animation_sprite.flip_h = true

func play_animation_with_color(base_anim: String):
	var anim_name = base_anim + couleur_active.capitalize()
	if animation_sprite.sprite_frames.has_animation(anim_name):
		animation_sprite.play(anim_name)
	else:
		animation_sprite.play(base_anim)

func trigger_yellow_platforms():
	for platform in get_tree().get_nodes_in_group("YellowPlatform"):
		platform.toggle()
		
func check_red_block_collision():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider and collider.is_in_group("RedBlock"):
			
			# CONDITION CLÉ
			if couleur_active == "rouge" and (animation_sprite.animation.begins_with("fall") || animation_sprite.animation.begins_with("shoot")):
				collider.destroy()
				
func tp_to_portal():
	if portal:
		tpSound.play()
		await get_tree().create_timer(1.0).timeout
		velocity = Vector2.ZERO
		global_position = portal.global_position
		tpSound.stop()
		
func update_detecteur_position(target: Node2D):
	var orbit_radius = 0  # distance entre le joueur et le détecteur
	var orbit_angle = 0.0  # tu peux modifier si tu veux le décaler

	# Position en orbite autour du joueur
	var offset = Vector2(cos(orbit_angle), sin(orbit_angle)) * orbit_radius
	detecteur.global_position = global_position + offset

	# Faire pointer le détecteur vers le Colorux le plus proche
	if target:
		var dir = (target.global_position - detecteur.global_position).normalized()
		var pivot_correction = deg_to_rad(90)
		detecteur.rotation = dir.angle() +pivot_correction
		
func find_closest_colorux() -> Node2D:
	var container = get_node("../../ColoruxContainer")
	if container == null:
		print("❌ ColoruxContainer introuvable !")
		return null
	
	var closest = null
	var min_dist = INF
	for c in container.get_children():
		var dist = global_position.distance_to(c.global_position)
		if dist < min_dist:
			min_dist = dist
			closest = c
	
	return closest
