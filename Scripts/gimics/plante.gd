extends StaticBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

@export var vineFinal :bool =false

var est_grande := false

# Layer constants
const LAYER_PLANTE = 2
const LAYER_JOUEUR = 1

func _ready():
	if vineFinal:
		collision_kill()
	# Collision activée pour que le rayon puisse détecter la plante
	collision.disabled = false
	
	# Ces propriétés sont sur le StaticBody2D, pas sur le CollisionShape2D
	#self.collision_layer = LAYER_PLANTE
	self.collision_mask = LAYER_JOUEUR
	
	if  self.collision_layer ==1:
		est_grande = true
	else:
		est_grande = false
	# Au départ, petite = traversable pour le joueur
	
	set_player_passable(true)

func grow():
	if est_grande:
		return
		
	est_grande = true
	set_player_passable(false)
	self.collision_layer = LAYER_JOUEUR
	
	sprite.play("grow")
	await sprite.animation_finished

	

func shrink():
	if not est_grande:
		return

	sprite.play_backwards("grow")
	await sprite.animation_finished

	est_grande = false
	set_player_passable(true)
	self.collision_layer = LAYER_PLANTE


func set_player_passable(passable: bool):
	# Godot 4 : layer index = layer number - 1
	# La plante est toujours sur layer 2
	# On modifie le mask pour savoir si elle détecte le joueur
	self.set_collision_mask_value(LAYER_JOUEUR, not passable)
	
func collision_kill():
	var k :Area2D= $Kill2D
	k.body_entered.connect(_on_k_body_entered)
	
func _on_k_body_entered(body):
	if est_grande:
		if body is PlayerController:
			body.die()
