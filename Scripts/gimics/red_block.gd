extends StaticBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

@onready var detector: Area2D = $SphereDetector

var destroyed := false

func _ready():
	# ➜ AJOUT : connexion du signal
	detector.area_entered.connect(_on_sphere_entered)


# ➜ AJOUT : fonction de détection adaptée
func _on_sphere_entered(area):
	if area.is_in_group("SphereRouge"):
		destroy()

func destroy():
	if destroyed:
		return
	
	destroyed = true
	
	# Désactive collision
	collision.set_deferred("disabled", true)
	
	# Lance animation
	anim.play("destruction")

func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "destruction":
		queue_free()
