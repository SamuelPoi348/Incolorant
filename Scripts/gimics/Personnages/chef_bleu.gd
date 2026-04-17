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
	"Pour perpétuer mon espèce nous devons acomplir le rituel des flames,",
	"Tu possède déja une îcone Tu pourrais m'aider alors?",
	"Il te suffit de retrouver les 5 habitants perdu et alors le foyer de la renaissance,",
	"pourra se mettre en marche"
]
var chef_bleu_dialogue_active_2: Array[String] = [
	"Reste m'aider stp."
]
var chef_bleu_dialogue_active_3: Array[String] = [
	"Merci mon ami tu peut continuer ton voyage désormais la grande porte est ouverte"
]


func _process(delta: float) -> void:
	if DialogManager.is_dialog_active:
		anim.play("default")
	else:
		anim.stop()

func _unhandled_input(event):
	if event.is_action_pressed("interagir") and player_in_range:
		if !DialogManager.is_dialog_active:
			
			# 🔥 PRIORITÉ AU DIALOGUE FINAL
			if tous_les_habitants_visites():
				DialogManager.start_dialog(global_position + Vector2(50,50), chef_bleu_dialogue_active_3)
			
			elif !first_dialog_done:
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
	
func tous_les_habitants_visites() -> bool:
	var habitants = get_tree().get_nodes_in_group("Habitant_Bleu")
	if habitants.is_empty():
		return false
	for h in habitants:
		if not h.is_visited():
			return false
	return true
