# sphere_rouge.gd
extends Area2D
@export var speed : float = 40.0
var direction : Vector2 = Vector2.ZERO
var ready_to_shoot : bool = false  # bouge seulement si true

func _ready():
	
	# Connecter le LifeTimer pour destruction automatique
	if $LifeTimer:
		$LifeTimer.connect("timeout", Callable(self, "_on_LifeTimer_timeout"))

func _process(delta):
	if ready_to_shoot:
		position += direction * speed * delta

func _on_LifeTimer_timeout():
	queue_free()  # détruit la sphère automatiquement
