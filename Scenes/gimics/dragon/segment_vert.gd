extends Node2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var vineFinal: bool = false

var busy := false
var est_grande := false


func _ready():
	if vineFinal:
		est_grande = true
		sprite.play("grow")
	else:
		est_grande = false
		sprite.play("default")


func grow():
	# 🔒 déjà en état grow → on ignore
	if busy or est_grande:
		return
	
	busy = true
	est_grande = true
	
	sprite.play("grow")
	await sprite.animation_finished
	
	busy = false


func shrink():
	# 🔒 déjà en shrink → on ignore
	if busy or not est_grande:
		return
	
	busy = true
	est_grande = false
	
	sprite.play_backwards("grow")
	await sprite.animation_finished
	
	busy = false
	
func is_grown():
	return est_grande
