extends Area2D

var player_in_range = false
var first_dialog_done = false
@onready var anim = $AnimatedSprite2D
var chef_bleu_dialog_active: Array[String] = [
	"Salut brave voyageur,",
	"aurait tu l'améabilité de rester à mes côté un peu.",
	"Je vais t'avouer que je me sens très seul depuis que mon peuple,",
	" a quasiment été anéanti durant le dernier siècle.",
	"Certe nous vivons longtemps mais nous ne somme pas imortel non plus,",
	"il suffit de nous éteindre pour que notre âme quite notre corps.",
	"Pour perpétuer mon espèce je dois rentrer en contact d'autre personne,",
	"maniant une couleur différente de la miène.",
	"Tu possède une îcone verte!! Tu pourrais m'aider alors?",
	"Il te suffit de partager ton histoire et alors le foyer de la renaissance,",
	"pourra se mettre en marche"
]
var chef_bleu_dialogue_active_2: Array[String] = [
	"Reste m'aider stp."
]
var chef_bleu_dialogue_active_3: Array[String] = [
	"Merci mon ami tu peut aller chercher l'îcone bleu elle pourrais te servir à l'avenir."
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
				DialogManager.start_dialog(global_position + Vector2(50,50), chef_bleu_dialog_active)
				first_dialog_done = true
			else:
				DialogManager.start_dialog(global_position + Vector2(50,50), chef_bleu_dialogue_active_2)




func _on_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		player_in_range = true
	else: 
		player_in_range = false
		DialogManager.dialog_lines= []


func _on_body_exited(body: Node2D) -> void:
	player_in_range = false
	DialogManager.dialog_lines= []
