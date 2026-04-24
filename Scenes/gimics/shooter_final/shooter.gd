extends Node2D

@export var shot_scene: PackedScene
@export var base_fire_rate: float = 20  # shots per second
@export var max_distance: float = 500.0
@onready var timer: Timer = $Timer

var slow_multiplier: float = 1.0


func _ready():
	add_to_group("Turret")

	timer.timeout.connect(_on_timer_timeout)
	update_timer()

	# Connect to player signal
	var main = get_tree().root.get_node("Main")
	if main:
		main.color_changed.connect(on_player_color_changed)


func update_timer():
	timer.wait_time = 1.0 / (base_fire_rate * slow_multiplier)


func _on_timer_timeout():
	shoot()


func shoot():
	if shot_scene == null:
		return

	var shot = shot_scene.instantiate()
	shot.global_position = global_position
	shot.max_distance = max_distance
	shot.direction = Vector2.UP.rotated(global_rotation)

	get_tree().current_scene.add_child(shot)


func on_player_color_changed(new_color: String):
	if new_color == "bleu":
		slow_multiplier = 0.1   # 50% fire rate
	else:
		slow_multiplier = 1.0

	update_timer()
