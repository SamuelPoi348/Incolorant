extends StaticBody2D

var fermé_ok = true
var récepteur_ok = true
var first_timer = true
var first_ouverture=true

var est_fermee = false
var cycle_termine = false

@onready var anim = $AnimatedSprite2D
@onready var collision = $CollisionShape2D
@onready var c = $Area2D
@onready var c4 = $Area2D2
@export var premiere_porte: bool =false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	c.body_entered.connect(_on_c_body_entered)
	c4.body_entered.connect(_on_c4_body_entered)
	collision.disabled=true


func _process(delta: float) -> void:
	if est_fermee:
		if récepteur_ok and tous_les_recepteurs_remplis():
			ouvrir_toutes_les_portes()
	
func _on_c_body_entered(body):
	if body is PlayerController:
		body.die()
		
func _on_c4_body_entered(body):
	if body is PlayerController and not est_fermee and not cycle_termine and premiere_porte:
		for porte in get_tree().get_nodes_in_group("Porte_Rouge"):
			if not porte.est_fermee:
				porte.est_fermee = true
				porte.anim.play("fermé")
				porte.collision.set_deferred("disabled", false)

		if first_timer:
			first_timer = false
			get_tree().get_first_node_in_group("Niveau").lancer_timer()
	
func ouvrir_toutes_les_portes():
	if first_ouverture:
		first_ouverture = false
		cycle_termine = true # 🔥 IMPORTANT
		for porte in get_tree().get_nodes_in_group("Porte_Rouge"):
			porte.ouvrir()
		récepteur_ok = false
		
func ouvrir():
	if est_fermee:
		est_fermee = false
		anim.play("ouvrir")
		collision.set_deferred("disabled", true)
					
func tous_les_recepteurs_remplis() -> bool:
	for r in get_tree().get_nodes_in_group("Récepteur_Rouge"):
		if r.animation_sprite.animation != "Remplis":
			return false
	return true
		
