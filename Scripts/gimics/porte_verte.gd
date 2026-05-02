extends Node2D

var ouvrir_ok = false
@onready var anim = $AnimatedSprite2D
@onready var collision = $CollisionShape2D
@onready var c = $CS2D
@onready var openSound = $OpenSound
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	openSound.bus = "SFX"
	c.body_entered.connect(_on_c_body_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if ouvrir_ok:
		openSound.play()
		anim.play("default")
		collision.disabled=true
		ouvrir_ok=false
	
		
func _on_c_body_entered(body):
	if body is PlayerController:
		body.die()
	
