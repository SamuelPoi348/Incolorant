extends Node2D

var player_in_range = false

var merchant_dialog: Array[String] = [
	"Bienvenue, petit !",
	"Tu cherches quelque chose ?",
	"Ou plutôt, qui es-tu ?",
	"Cette île regorge de surprises, je suis sûr que tu trouveras.",
	"Sinon, si tu trouves des colorux, amène-les-moi et je t'offrirai de sublimes artéfacts.",
	"Qu'est-ce que c'est ? C'est simple, il ressemble à l'objet au-dessus de mon sac."
]

func _unhandled_input(event):
	if event.is_action_pressed("interagir") and player_in_range:
		if !DialogManager.is_dialog_active:
			DialogManager.start_dialog(global_position + Vector2(50,50), merchant_dialog)


func _on_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		player_in_range = true
	else: 
		player_in_range = false


func _on_body_exited(body: Node2D) -> void:
	player_in_range = false
