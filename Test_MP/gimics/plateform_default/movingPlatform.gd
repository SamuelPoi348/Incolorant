extends CharacterBody2D

class_name MovingPlatform

enum PlatformState { AT_ORIGIN, AT_TARGET, MOVING }

@export var move_offset: Vector2 = Vector2(0, -96) # Relative movement (3 tiles up if 32px tiles)
@export var move_speed: float = 100.0

var origin_position: Vector2
var target_position: Vector2

var current_state: PlatformState = PlatformState.AT_ORIGIN
var moving_to_target: bool = false

func _ready():
	# Save original position on scene load
	origin_position = global_position
	
	# Compute target RELATIVE to origin
	target_position = origin_position + move_offset
	
	add_to_group("YellowPlatform")


func _physics_process(delta):
	if current_state == PlatformState.MOVING:
		_move_platform(delta)


# =====================================================
# TOGGLE
# =====================================================

func toggle():
	if current_state == PlatformState.MOVING:
		return
	
	if current_state == PlatformState.AT_ORIGIN:
		moving_to_target = true
	else:
		moving_to_target = false
	
	current_state = PlatformState.MOVING


# =====================================================
# MOVEMENT
# =====================================================

func _move_platform(delta):
	var destination = target_position if moving_to_target else origin_position
	
	var direction = destination - global_position
	
	# Snap when close enough
	if direction.length() < 1.0:
		global_position = destination
		velocity = Vector2.ZERO
		
		current_state = PlatformState.AT_TARGET if moving_to_target else PlatformState.AT_ORIGIN
		return
	
	velocity = direction.normalized() * move_speed
	move_and_slide()
