extends Control

func _ready():
	var main = get_tree().root.get_node("Main")
	var chemin_niveau : String = "res://Scenes/Zones/Plage_Grise/PG-1.tscn"
	if chemin_niveau in main.niveaux_completes:
			visible = false
	pass

func _on_button_button_down() -> void:
	get_tree().paused = false
	visible = false
