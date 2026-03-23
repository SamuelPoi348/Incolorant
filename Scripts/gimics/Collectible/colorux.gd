extends Area2D

@export var id_colorux : String

func _ready():
	var niveau = get_tree().current_scene.scene_file_path
	
	if get_tree().root.get_node("Main").colorux_deja_pris(niveau, id_colorux):
		queue_free()

func _on_body_entered(body):
	if body is PlayerController:
		var niveau = get_tree().current_scene.scene_file_path
		get_tree().root.get_node("Main").enregistrer_colorux(niveau, id_colorux)
		queue_free() # optionnel si c'est un collectible
