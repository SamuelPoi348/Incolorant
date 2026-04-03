extends Area2D

var main
@onready var collision = $CollisionShape2D

func _ready():
	main = get_tree().root.get_node("Main")
	if main.icone_jaune:
		visible=false
		collision.disabled = true
	pass
	
func _on_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		main.icone_jaune = true
		for node in get_tree().get_nodes_in_group("tuto_jaune"):
			node.visible = true
		queue_free() # optionnel si c'est un collectible
