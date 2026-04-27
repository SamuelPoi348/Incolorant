extends Control

var can_continue := false
@onready var texture = $TextureRect
var main

func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS


func start_credits():
	visible = true
	can_continue = false
	
	await get_tree().create_timer(2.0).timeout
	
	can_continue = true


func _process(delta):
	if not visible:
		return
	main = get_tree().root.get_node("Main")
	if main.secret_ending:
		texture.texture = load("res://sprites/incolorant_cover_art.png")
	if can_continue and Input.is_action_just_pressed("interagir"):
		show_restart()


func show_restart():
	var restart_nodes = get_tree().get_nodes_in_group("restart")
	visible=false
	for r in restart_nodes:
		r.visible = true
	
