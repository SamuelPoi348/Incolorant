extends Control

var spawn_position: Vector2 = Vector2.ZERO
var main
var retour_effectue = false
func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	main = get_tree().root.get_node("Main")
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	for child in get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_STOP



func _process(delta):
	if main.scene_courante == "mort" and not retour_effectue:
		retour_effectue = true
		_on_retour_button_down()

func _on_recommencer_button_down() -> void:
	Engine.time_scale = 1.0
	var scene = main.niveau_courant
	main.call_deferred("change_scene", scene)


func _on_retour_button_down() -> void:
	Engine.time_scale = 1.0
	spawn_position = main.position_courante
	var scene_resource = preload("res://Scenes/Zones/map/map.tscn") 
	main.scene_courante= "res://Scenes/Zones/map/map.tscn"
	main.call_deferred("change_scene", scene_resource, spawn_position)


func _on_quitter_button_down() -> void:
	get_tree().quit()
