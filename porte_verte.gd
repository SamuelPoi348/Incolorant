extends Node2D

var ouvrir_ok = false
@onready var anim = $AnimatedSprite2D
@onready var collision = $CollisionShape2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if ouvrir_ok:
		anim.play("default")
		collision.disabled=true
		ouvrir_ok=false
	pass
