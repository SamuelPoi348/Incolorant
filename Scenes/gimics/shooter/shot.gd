extends StaticBody2D

@export var speed: float = 400.0
var direction: Vector2 = Vector2.RIGHT

func _process(delta):
	position += direction * speed * delta

	# Optional: remove if off-screen
	if position.length() > 5000:
		queue_free()
