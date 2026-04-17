extends StaticBody2D

var allume = false
@onready var anim = $AnimatedSprite2D

func _ready() -> void:
	if anim:
		anim.frame = 0
		anim.stop() # foyer éteint au départ

func _process(delta: float) -> void:
	if not allume and tous_les_habitants_visites():
		allumer_foyer()

func tous_les_habitants_visites() -> bool:
	var habitants = get_tree().get_nodes_in_group("Habitant_Bleu")
	if habitants.is_empty():
		return false
	for h in habitants:
		if not h.is_visited():
			return false
	return true

func allumer_foyer():
	allume = true
	if anim:
		anim.play("allumer")
