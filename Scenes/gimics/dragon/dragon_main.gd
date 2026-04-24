# dragon_main.gd
# ==============================================================================
# DRAGON SNAKE MOVEMENT SYSTEM
# Implements snake-like sequential movement where each segment follows the one
# before it. Control with ui_up, ui_down, ui_left, ui_right. Freezes when no
# input is held.
# ==============================================================================

extends StaticBody2D

# Segment Configuration
@export var segment_scene: PackedScene
@export var segment_scene_with_shooter: PackedScene
@export var segment_scene_vert: PackedScene
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


func _ready():
	head_position = global_position
	
	# Initialize segment positions
	# CHANGER LES SEGMENTS ICI
	#  
	for i in range(num_segments - 1):
		var seg

		if i == 2:
			seg = segment_scene_vert.instantiate()
		elif i == 4:
			seg = segment_scene_with_shooter.instantiate()
		else:
			seg = segment_scene.instantiate()
	

		get_parent().add_child.call_deferred(seg)
		segments.append(seg)
		segment_positions.append(head_position - Vector2(segment_spacing * (i + 1), 0))





func _process(delta):
	_handle_input()
	
	if current_direction.length() > 0:
		is_moving = true
		head_position += current_direction * movement_speed * delta
	else:
		is_moving = false
	
	_update_segments(delta)
	
	_update_visuals()


func _handle_input():
	"""Debug input handling for movement"""
	var input_direction = Vector2.ZERO
	
	if Input.is_action_pressed("ui_up"):
		input_direction.y -= 1
	if Input.is_action_pressed("ui_down"):
		input_direction.y += 1
	if Input.is_action_pressed("ui_left"):
		input_direction.x -= 1
	if Input.is_action_pressed("ui_right"):
		input_direction.x += 1
	
	if input_direction.length() > 0:
		current_direction = input_direction.normalized()
	else:
		current_direction = Vector2.ZERO


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
	
	if current_direction.length() > 0:
		rotation = current_direction.angle()
	
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
