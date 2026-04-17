extends StaticBody2D

var fermé_ok = false  # Door starts closed until all habitants are visited
var habitants_ok = true
@onready var anim = $AnimatedSprite2D
@onready var collision = $CollisionShape2D

func _ready() -> void:
	add_to_group("Porte_Bleu")
	# Door starts closed - collision is active, animation at frame 0 (closed state)
	collision.disabled = false
	if anim:
		anim.frame = 0
		anim.stop()

func _process(delta: float) -> void:
	if not fermé_ok:
		if habitants_ok and tous_les_habitants_visites():
			ouvrir_toutes_les_portes()

func tous_les_habitants_visites() -> bool:
	var habitants = get_tree().get_nodes_in_group("Habitant_Bleu")
	if habitants.is_empty():
		return false
	for h in habitants:
		if not h.is_visited():
			return false
	return true

func ouvrir_toutes_les_portes():
	for porte in get_tree().get_nodes_in_group("Porte_Bleu"):
		porte.ouvrir()
	habitants_ok = false

func ouvrir():
	if not fermé_ok:
		fermé_ok = true
		if anim:
			anim.play("default")  # Play the opening animation
		collision.set_deferred("disabled", true)
