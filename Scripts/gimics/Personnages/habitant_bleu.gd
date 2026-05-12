extends Area2D

@export var habitant_id: int = 0
var visited = false
var waiting_for_dialog_end=false
@export var village_position: Vector2

var dialogues_random: Array = [
	["Merciiii !!! Tu m'as trouvé !"] as Array[String],
	["Youpiii ! Enfin quelqu’un !"] as Array[String],
	["C’est fire 🔥 merci à toi !"] as Array[String]
]
func _ready() -> void:
	add_to_group("Habitant_Bleu")
	body_entered.connect(_on_body_entered)
	DialogManager.dialog_finished.connect(_on_dialog_finished)
	randomize()

func _on_body_entered(body):
	if body.is_in_group("Player") and not visited:
		if !DialogManager.is_dialog_active:
			visited = true
			waiting_for_dialog_end = true
		
			var random_index = randi() % dialogues_random.size()
			var chosen_dialog = dialogues_random[random_index]
			
			DialogManager.start_dialog(global_position + Vector2(50,50), chosen_dialog)
			print("Habitant bleu %d visited!" % habitant_id)
			

func is_visited() -> bool:
	return visited
	
func _on_dialog_finished():
	if waiting_for_dialog_end:
		waiting_for_dialog_end = false
		global_position = village_position
