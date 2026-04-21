extends CharacterBody2D
class_name MovingPlatform

enum PlatformState { AT_ORIGIN, AT_TARGET, MOVING }

@export var move_offset: Vector2 = Vector2(0, -96)
@export var move_speed: float = 100.0

var origin_position: Vector2
var target_position: Vector2
var current_state: PlatformState = PlatformState.AT_ORIGIN
var moving_to_target: bool = false

@onready var a = $Area2D

func _ready():
	a.body_entered.connect(_on_a_body_entered)
	origin_position = global_position
	target_position = origin_position + move_offset
	add_to_group("YellowPlatform")

func _physics_process(delta):
	var main = get_tree().root.get_node("Main")
	
	# 🚫 Stop total pendant la sélection
	if main.selecting_color:
		return
	process_physics_priority = -1
	if current_state == PlatformState.MOVING:
		_move_platform(delta)

func toggle():
	if current_state == PlatformState.MOVING:
		return
	moving_to_target = current_state == PlatformState.AT_ORIGIN
	current_state = PlatformState.MOVING

func _move_platform(delta):
	var destination = target_position if moving_to_target else origin_position
	var direction = destination - global_position

	if direction.length() < 1.0:
		global_position = destination
		current_state = PlatformState.AT_TARGET if moving_to_target else PlatformState.AT_ORIGIN
		return

	var movement = direction.normalized() * move_speed * delta
	global_position += movement
	
func _on_a_body_entered(body):
	if body is PlayerController:
		body.die()
