extends Control

#@onready var option = $Option

@onready var button_quitter_map =$PanelContainer/VBoxContainer/quitter_map
var spawn_position: Vector2 = Vector2.ZERO
var main 
func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	
	main = get_tree().root.get_node("Main")
	if main.scene_courante != "res://Scenes/Zones/map/map.tscn":
		button_quitter_map.disabled = false
		button_quitter_map.visible = true
	else:
		button_quitter_map.disabled = true
		button_quitter_map.visible = false
	
func resume():
	get_tree().paused = false
	visible = false


func pause():
	get_tree().paused = true
	visible = true

	
func _input(event):
	if event.is_action_pressed("pause"):
		if get_tree().paused:
			resume()
		else:
			pause()


func _on_commencer_button_down() -> void:
	resume()


func _on_option_button_down() -> void:
	var option = get_tree().get_first_node_in_group("Option")
	
	if option:
		option.visible = true
		option.process_mode = Node.PROCESS_MODE_ALWAYS
		visible = false


func _on_quitter_button_down() -> void:
	get_tree().quit()
	


func _on_quitter_map_button_down() -> void:
	main.color_locked =false
	main.scene_courante = "mort"
	get_tree().paused = false
	Engine.time_scale = 1.0

	# Cache Pause
	visible = false
	
	# Affiche Mort
	var mort_node = get_parent().get_node("Mort")
	mort_node.visible = true
