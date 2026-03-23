extends Control
@onready var test = preload("res://Scenes/ScenePresentation.tscn")
@onready var l1 = preload("res://Scenes/Zones/Plage_Grise/PG-1.tscn")

@onready var option = preload("res://Scenes/ui/option.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_commencer_button_down() -> void:
	await get_tree().create_timer(1).timeout
	get_tree().root.get_node("Main").change_scene(l1)


func _on_option_button_down() -> void:
	get_tree().root.get_node("Main").change_scene(option)


func _on_quitter_button_down() -> void:
	get_tree().quit()
