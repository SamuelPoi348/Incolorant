extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		get_tree().root.get_node("Main").icone_bleu = true
		queue_free() # optionnel si c'est un collectible
