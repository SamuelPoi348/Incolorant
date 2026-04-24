extends StaticBody2D

@export var speed: float = 400.0
var direction: Vector2 = Vector2.RIGHT
var max_distance: float = 500.0
var distance_traveled: float = 0.0

func _ready():
	rotation = direction.angle()

func _process(delta):
	var step = speed * delta
	position += direction * step
	distance_traveled += step
	if distance_traveled >= max_distance:
		queue_free()
