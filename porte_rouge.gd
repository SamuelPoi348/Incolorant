extends StaticBody2D

var fermé_ok = true
var récepteur_ok = true
@onready var anim = $AnimatedSprite2D
@onready var collision = $CollisionShape2D
@onready var c = $Area2D
@onready var c4 = $Area2D2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	c.body_entered.connect(_on_c_body_entered)
	c4.body_entered.connect(_on_c4_body_entered)
	collision.disabled=true


func _process(delta: float) -> void:
	if not fermé_ok:
		if récepteur_ok && tous_les_recepteurs_remplis():
			ouvrir_toutes_les_portes()
	
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
	
func ouvrir_toutes_les_portes():
	for porte in get_tree().get_nodes_in_group("Porte_Rouge"):
		porte.ouvrir()
	récepteur_ok=false
		
func ouvrir():
	if not fermé_ok:
		fermé_ok = true
		anim.play("ouvrir") # adapte au nom de ton anim
		collision.set_deferred("disabled", true)
					
func tous_les_recepteurs_remplis() -> bool:
	for r in get_tree().get_nodes_in_group("Récepteur_Rouge"):
		if r.animation_sprite.animation != "Remplis":
			return false
	return true
		
