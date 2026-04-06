extends Area2D

var player_in_range = false
var first_dialog_done = false
@onready var anim = $AnimatedSprite2D
var chef_jaune_dialog_active: Array[String] = [
	"Salut mon gars t'est allé dans la forêt hein.",
	"Tu est dans mon territoire alors si tu veut faire parti des notres il vas falloir que tu parcours ma ville.",
	"Je vais être clément avec toi je vais te laisser une minute",
	"Si tu n'y arrive pas je relâche mes citoyen sur toi,",
	"je te le dis tous de suite ils te tueront!"
]
var chef_jaune_dialogue_active_2: Array[String] = [
	"Tu vas y aller oui, sinon je te laisse 1 seconde!"
]


func _process(delta: float) -> void:
	if DialogManager.is_dialog_active:
		anim.play("default")
	else:
		anim.stop()
		
func _unhandled_input(event):
	if event.is_action_pressed("interagir") and player_in_range:
		if !DialogManager.is_dialog_active:
			if !first_dialog_done:
				DialogManager.start_dialog(global_position + Vector2(50,50), chef_jaune_dialog_active)
				first_dialog_done = true
			else:
				DialogManager.start_dialog(global_position + Vector2(50,50), chef_jaune_dialogue_active_2)



func _on_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		player_in_range = true
	else: 
		player_in_range = false
		DialogManager.dialog_lines= []


func _on_body_exited(body: Node2D) -> void:
	player_in_range = false
	DialogManager.dialog_lines= []
