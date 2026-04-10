extends StaticBody2D

var fermé_ok = true
@onready var anim = $AnimatedSprite2D
@onready var collision = $CollisionShape2D
@onready var c = $Area2D
@onready var c4 = $Area2D2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	c.body_entered.connect(_on_c_body_entered)
	c4.body_entered.connect(_on_c4_body_entered)
	collision.disabled=true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_c_body_entered(body):
	if body is PlayerController:
		body.die()
		
func _on_c4_body_entered(body):
	if body is PlayerController and fermé_ok:
		for porte in get_tree().get_nodes_in_group("Porte_Rouge"):
			if porte.fermé_ok:
				porte.fermé_ok = false
				porte.anim.play("fermé")
				porte.collision.set_deferred("disabled", false)
		
