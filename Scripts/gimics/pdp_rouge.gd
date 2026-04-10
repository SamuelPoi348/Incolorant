extends StaticBody2D

@onready var anim = $AnimatedSprite2D
@onready var collision = $CollisionShape2D
@onready var c = $Area2D

func _ready() -> void:
	c.body_entered.connect(_on_c_body_entered)
	

func _on_c_body_entered(body):
	if body is PlayerController:
		anim.play("appuyer")
