extends Area2D

@export var id_colorux : String

@onready var coin_sound = $CoinSound
var main

func _ready():
	main = get_tree().root.get_node("Main")
	var niveau = get_tree().current_scene.scene_file_path
	coin_sound.bus = "SFX"
	if get_tree().root.get_node("Main").colorux_deja_pris(niveau, id_colorux):
		queue_free()

func _on_body_entered(body):
	if body is PlayerController:
		var niveau = get_tree().current_scene.scene_file_path
		get_tree().root.get_node("Main").enregistrer_colorux(niveau, id_colorux)
		
		coin_sound.play()
		
		# attendre la fin du son avant de supprimer
		await coin_sound.finished
		if not main.admin:
			main.sauvegarder()
		queue_free()
