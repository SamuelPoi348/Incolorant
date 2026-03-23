extends StaticBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

var destroyed := false

func destroy():
	if destroyed:
		return
	
	destroyed = true
	
	# Désactive collision
	collision.disabled = true
	
	# Lance animation
	anim.play("destruction")

func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "destruction":
		queue_free()
