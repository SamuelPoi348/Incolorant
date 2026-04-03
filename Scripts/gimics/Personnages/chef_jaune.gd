extends Area2D

var player_in_range = false
var first_dialog_done = false
@onready var anim = $AnimatedSprite2D
var chef_rouge_dialog_active: Array[String] = [
	"T'est le petit qui a fait ses preuves chez les autres tribus.",
	"Je suis le chef rouge, bouillonnant comme ce volcan.",
	"Montre-moi ce que tu as dans le ventre, ou plutôt dans l'arène.",
	"Si tu parviens à m'impressionner, moi et mes sujets,",
	"je te donnerai l'icône rouge pour que tu ailles pourfendre ce dragon."
]
var chef_rouge_dialogue_active_2: Array[String] = [
	"Tu vas y aller, tabarnak, ou je te lance moi-même dedans !"
]


func _process(delta: float) -> void:
	if DialogManager.is_dialog_active:
		anim.play("default")
		
func _unhandled_input(event):
	if event.is_action_pressed("interagir") and player_in_range:
		if !DialogManager.is_dialog_active:
			if !first_dialog_done:
				DialogManager.start_dialog(global_position + Vector2(50,50), chef_rouge_dialog_active)
				first_dialog_done = true
			else:
				DialogManager.start_dialog(global_position + Vector2(50,50), chef_rouge_dialogue_active_2)



func _on_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		player_in_range = true
	else: 
		player_in_range = false
		DialogManager.dialog_lines= []


func _on_body_exited(body: Node2D) -> void:
	player_in_range = false
	DialogManager.dialog_lines= []
