extends Area2D

@onready var hitbox = $StaticBody2D/Centre
@onready var anim = $AnimatedSprite2D

var player_inside = false
var main
var porte_ouverte = false


func _ready():
	main = get_tree().root.get_node("Main")

	body_shape_entered.connect(_on_body_shape_entered)
	body_shape_exited.connect(_on_body_shape_exited)


func _process(_delta):
	if player_inside and Input.is_action_just_pressed("interagir") and !porte_ouverte:
		verifier_conditions()


func verifier_conditions():

	if main.icone_bleu and main.icone_rouge and main.icone_jaune and main.icone_vert:
		ouvrir_porte()


func ouvrir_porte():
	porte_ouverte = true
	anim.play("ouverture")

	if hitbox:
		hitbox.queue_free()


func _on_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body.name == "PlayerMap":
		player_inside = true


func _on_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	if body.name == "PlayerMap":
		player_inside = false
