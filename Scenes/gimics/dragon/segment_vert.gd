extends Node2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var vineFinal: bool = false

var busy := false
var is_grown := false


func _ready():
	if vineFinal:
		is_grown = true
		sprite.play("grow")
	else:
		is_grown = false
		sprite.play("default")


func grow():
	# 🔒 déjà en état grow → on ignore
	if busy or is_grown:
		return
	
	busy = true
	is_grown = true
	
	sprite.play("grow")
	await sprite.animation_finished
	
	busy = false


func shrink():
	# 🔒 déjà en shrink → on ignore
	if busy or not is_grown:
		return
	
	busy = true
	is_grown = false
	
	sprite.play_backwards("grow")
	await sprite.animation_finished
	
	busy = false
