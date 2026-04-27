extends Control

@export var spawn_position: Vector2 = Vector2.ZERO
@onready var btn_menu = $VBoxContainer/Button
@onready var btn_retour_map = $VBoxContainer/Button2

var main

func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	main = get_tree().root.get_node("Main")
	
	btn_menu.pressed.connect(_on_menu_pressed)
	btn_retour_map.pressed.connect(_on_map_pressed)
	
func _on_map_pressed():
		get_tree().paused = false
	
		main.color_locked = false
	
		var target_pos = global_position if spawn_position == Vector2.ZERO else spawn_position
		main.scene_courante = "res://Scenes/Zones/map/map.tscn"
	
		main.call_deferred("change_scene", preload("res://Scenes/Zones/map/map.tscn"), target_pos)
		
func _on_menu_pressed():
	get_tree().paused = false
	
	main.reset_game()
	
	var menu = load("res://Scenes/important_function/Menu_Principal.tscn")
	main.change_scene(menu)
	
