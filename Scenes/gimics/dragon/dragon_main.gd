# dragon_main.gd
# ==============================================================================
# DRAGON SNAKE MOVEMENT SYSTEM
# Implements snake-like sequential movement where each segment follows the one
# before it. Control with ui_up, ui_down, ui_left, ui_right. Freezes when no
# input is held.
# ==============================================================================

extends Node2D

# Segment Configuration
@export var segment_scene: PackedScene
@export var segment_scene_with_shooter: PackedScene
@export var segment_scene_vert: PackedScene
@export var segment_scene_fin: PackedScene
@export var segment_scene_rouge: PackedScene
@export var segment_scene_jaune: PackedScene
@export var num_segments: int = 5
@export var segment_spacing: float = 25.0
@export var movement_speed: float = 150.0
@export var follow_speed_multiplier: float = 1.0

# Internal State
var head_position: Vector2 = Vector2.ZERO
var segment_positions: Array[Vector2] = []
var current_direction: Vector2 = Vector2.ZERO
var is_moving: bool = false

var segments: Array[Node] = []
var history: Array[Vector2] = []

@export var path_follow: PathFollow2D
@export var speed: float = 50

var boss_phase_complete := false

@onready var area2D = $Area2D
@onready var area2D2 = $Area2D2
@onready var anim = $Sprite2D

var head_hit_count := 0
var head_hit_max := 5
var head_vulnerable := false

var player_in_alt_area := false
var player_ref = null
var secret_ending = false
var main

func _ready():
	area2D.body_entered.connect(_on_head_hit)
	head_position = global_position
	
	area2D2.body_entered.connect(_on_alt_enter)
	area2D2.body_exited.connect(_on_alt_exit)
	# Initialize segment positions
	# CHANGER LES SEGMENTS ICI
	#  
	for i in range(num_segments - 1):
		var seg

		if i == 2:
			seg = segment_scene_vert.instantiate()
		elif i == 4:
			seg = segment_scene_with_shooter.instantiate()
		elif i == 10: 
			seg = segment_scene_rouge.instantiate()
		elif i == 8:
			seg = segment_scene_jaune.instantiate()
		elif i == 15:
			seg = segment_scene_vert.instantiate()
		elif i == 20:
			seg = segment_scene_rouge.instantiate()
		elif i == 27:
			seg = segment_scene_jaune.instantiate()
		elif i == 30:
			seg = segment_scene_with_shooter.instantiate()
		elif i == 35:
			seg = segment_scene_vert.instantiate()
		elif i == num_segments-2:
			seg = segment_scene_fin.instantiate()
		else:
			seg = segment_scene.instantiate()
	

		get_tree().root.add_child(seg)
		segments.append(seg)
		segment_positions.append(head_position - Vector2(segment_spacing * (i + 1), 0))







func _process(delta):
	var pf = get_parent() as PathFollow2D
	
	if pf == null:
		return
	_check_alternative_kill()
	check_boss_state()
	
	# DEBUG: Press J to kill boss
	if Input.is_action_just_pressed("ui_j"):
		kill_boss()
	
	# avancer sur le chemin
	pf.progress += speed * delta
	
	# la position est AUTOMATIQUE (héritée du parent)
	head_position = global_position
	
	# direction automatique
	current_direction = pf.transform.x.normalized()
	
	is_moving = true
	
	_update_segments(delta)
	_update_visuals()

func _on_alt_enter(body):
	if body.is_in_group("Player"):
		player_in_alt_area = true
		player_ref = body

func _on_alt_exit(body):
	if body.is_in_group("Player"):
		player_in_alt_area = false
		player_ref = null
		
func _update_segments(delta):
	"""Update all segment positions to follow each other while maintaining spacing"""
	if segment_positions.size() == 0:
		return
	
	var direction_to_head = (head_position - segment_positions[0]).normalized()
	var target_pos = head_position - direction_to_head * segment_spacing
	segment_positions[0] = segment_positions[0].lerp(target_pos, follow_speed_multiplier * delta * 5.0)
	
	for i in range(1, segment_positions.size()):
		var prev_segment_pos = segment_positions[i - 1]
		var current_pos = segment_positions[i]
		
		var direction = (prev_segment_pos - current_pos).normalized()
		var target_pos_1 = prev_segment_pos - direction * segment_spacing
		
		segment_positions[i] = current_pos.lerp(target_pos_1, follow_speed_multiplier * delta * 5.0)


func _update_visuals():
	"""Update the visual representation of the dragon"""
	global_position = head_position
	
	#if current_direction.length() > 0:
		#rotation = path_follow.rotation
	
	for i in range(segments.size()):
		if segments[i] != null and i < segment_positions.size():
			segments[i].global_position = segment_positions[i]
			
			if i == 0:
				var direction_to_head = (head_position - segment_positions[i]).normalized()
				segments[i].rotation = direction_to_head.angle()
			else:
				var direction_to_next = (segment_positions[i - 1] - segment_positions[i]).normalized()
				segments[i].rotation = direction_to_next.angle()



# ==============================================================================
# PUBLIC API
# ==============================================================================

func set_direction(direction: Vector2):
	"""Set the movement direction (normalized)"""
	if direction.length() > 0:
		current_direction = direction.normalized()
	else:
		current_direction = Vector2.ZERO


func freeze():
	"""Stop all movement"""
	current_direction = Vector2.ZERO
	is_moving = false


func get_head_position() -> Vector2:
	"""Get the head position"""
	return head_position


func get_segment_position(segment_index: int) -> Vector2:
	"""Get the position of a specific segment (0 is head, 1+ are body segments)"""
	if segment_index == 0:
		return head_position
	if segment_index - 1 < segment_positions.size():
		return segment_positions[segment_index - 1]
	return head_position


func get_all_segment_positions() -> Array[Vector2]:
	"""Get all segment positions"""
	var positions: Array[Vector2] = [head_position]
	positions.append_array(segment_positions)
	return positions


func is_currently_moving() -> bool:
	"""Check if dragon is currently moving"""
	return is_moving
	
func check_boss_state():
	var all_red_done := true
	var all_yellow_done := true
	var all_green_done := true
	
	for seg in segments:
		
		# 🔴 RED (shatter)
		if seg.has_method("is_shattered"):
			if not seg.is_shattered():
				all_red_done = false
		
		# 🟡 YELLOW (move activé)
		if seg.has_method("is_yellow_active"):
			if not seg.is_yellow_active():
				all_yellow_done = false
		
		# 🟢 GREEN (grow activé)
		if seg.has_method("is_grown"):
			if not seg.is_grown():
				all_green_done = false
	
	if all_red_done and all_yellow_done and all_green_done:
		if not boss_phase_complete:
			boss_phase_complete = true
			head_vulnerable = true
			print("🔥 BOSS PHASE COMPLETE")
			
func _on_head_hit(body):
	if not boss_phase_complete:
		return
	
	if not head_vulnerable:
		return
	
	if not body.is_in_group("Player"):
		return
	
	# vérifier attaque joueur
	var anim = body.animation_sprite.animation
	
	if anim.begins_with("fall") or anim.begins_with("shoot"):
		register_head_hit()
		
func register_head_hit():
	if head_hit_count >= head_hit_max:
		return
	
	head_hit_count += 1
	
	print("HEAD HIT:", head_hit_count, "/", head_hit_max)
	
	# animation hit tête
	play_head_hit_anim()
	
	if head_hit_count >= head_hit_max:
		main = get_tree().root.get_node("Main")
		main.secret_ending=false
		kill_boss()
		
func play_head_hit_anim():
	# si tu as une anim sur la tête
	anim.play("hit")
	await anim.animation_finished
	anim.play("default")
			
func kill_boss():
	print("💀 BOSS DEAD")
	head_vulnerable = false
	
	# 1️⃣ FREEZE THE DRAGON
	freeze()
	speed = 0
	
	# 1️⃣.5️⃣ FREEZE THE PLAYER
	var player = null
	# Try to find PlayerController script instance
	for node in get_tree().get_nodes_in_group("Player"):
		player = node
		break
	if player:
		player.set_physics_process(false)
	
	# 2️⃣ SCREEN SHAKE + FADE ANIMATION + PLAYER TELEPORT
	await _screen_shake_and_fade(player)
	
	# 3️⃣ RE-ENABLE PLAYER PHYSICS SO CAMERA TRACKS THEM
	if player:
		player.set_physics_process(true)
	
	# 4️⃣ CALL POST-BOSS FUNCTION
	post_kill_boss()


func _screen_shake_and_fade(player: Node) -> void:
	var camera = player.get_node_or_null("Camera2D")  # Get from player, not viewport
	if camera == null:
		return

	var shake_intensity = 7.0
	var shake_duration = 2.5
	var fade_duration = 5

	# Setup fade overlay (same as before)
	var fade_overlay = CanvasLayer.new()
	fade_overlay.layer = 100
	get_tree().root.add_child(fade_overlay)

	var color_rect = ColorRect.new()
	color_rect.color = Color(1, 1, 1, 0)
	color_rect.anchor_right = 1
	color_rect.anchor_bottom = 1
	fade_overlay.add_child(color_rect)

	# Run shake in background
	_shake_camera(camera, shake_intensity, shake_duration)

	# Fade to white
	var fade_tween = create_tween()
	fade_tween.tween_property(color_rect, "color", Color(1, 1, 1, 1), fade_duration)
	await fade_tween.finished

	# Screen is white — teleport player
	if player:
		player.position = Vector2(3250, -210)

		# Snap camera using local position + reset_smoothing
		camera.position = Vector2.ZERO  # local offset from player
		camera.reset_smoothing()

	# Fade out
	var fade_out_tween = create_tween()
	fade_out_tween.tween_property(color_rect, "color", Color(1, 1, 1, 0), fade_duration)
	await fade_out_tween.finished

	fade_overlay.queue_free()


# No longer takes original_pos — uses LOCAL position offset instead
func _shake_camera(camera: Camera2D, intensity: float, duration: float) -> void:
	var original_local_pos = camera.position  # store LOCAL position
	for i in range(int(duration * 30)):
		camera.position = original_local_pos + Vector2(  # set LOCAL position
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		await get_tree().create_timer(duration / 30).timeout
	camera.position = original_local_pos  # restore LOCAL position


func post_kill_boss() -> void:
	"""Called after death animation completes - override or connect signals here"""
	# Add your post-boss logic here (level complete, rewards, etc.)

func _check_alternative_kill():
	if not player_in_alt_area:
		return
	
	if boss_phase_complete:
		return
	
	if player_ref == null:
		return
	
	# Vérifie couleur vide
	if player_ref.couleur_active != "":
		return
	
	# Input
	if Input.is_action_just_pressed("interagir"):
		secret_ending=true
		main = get_tree().root.get_node("Main")
		main.secret_ending=true
		print("🧪 ALT KILL TRIGGERED")
		kill_boss()
