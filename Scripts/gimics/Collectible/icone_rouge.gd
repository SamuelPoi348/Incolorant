extends Area2D

var main

func _ready():
	main = get_tree().root.get_node("Main")
	if main.icone_rouge:
		visible=false
	pass
	
func _on_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		main.icone_rouge = true
		for node in get_tree().get_nodes_in_group("tuto_rouge"):
			node.visible = true
		queue_free() # optionnel si c'est un collectible
