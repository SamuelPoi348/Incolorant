extends Area2D

var main
@onready var collision = $CollisionShape2D
@onready var pickup = $PickUpSound

func _ready():
	pickup.bus = "SFX"
	main = get_tree().root.get_node("Main")
	if main.icone_jaune:
		visible=false
		collision.disabled = true
	pass
	
func _on_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		pickup.play()
		main.icone_jaune = true
		for node in get_tree().get_nodes_in_group("tuto_jaune"):
			node.visible = true
		await pickup.finished
		queue_free() # optionnel si c'est un collectible
