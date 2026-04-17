extends Area2D

@export var habitant_id: int = 0
var visited = false

func _ready() -> void:
	add_to_group("Habitant_Bleu")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("Player") and not visited:
		visited = true
		print("Habitant bleu %d visited!" % habitant_id)

func is_visited() -> bool:
	return visited
