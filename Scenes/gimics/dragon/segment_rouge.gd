extends Node2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var area: Area2D = $Area2D

var hit_count := 0
var max_hits := 3
var broken := false
var busy := false


func _ready():
	area.body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	if broken or busy:
		return
	
	# Vérifie joueur
	if not body.is_in_group("Player"):
		return
	
	# Vérifie couleur
	if body.couleur_active != "rouge":
		return
	
	# Vérifie animation joueur
	var player_anim = body.animation_sprite.animation
	if not (player_anim.begins_with("fall") or player_anim.begins_with("shoot")):
		return
	
	# COMPTE HIT
	hit_count += 1
	print("Hit:", hit_count, "/", max_hits)
	
	# SHATTER FINAL
	if hit_count >= max_hits:
		broken = true
		anim.play("shatter")
		return
	
	# HIT INTERMEDIAIRE
	busy = true
	anim.play("hit")
	
	await anim.animation_finished
	
	if not broken:
		anim.play("default")
	
	busy = false
