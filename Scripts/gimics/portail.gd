extends Area2D

@export var next_scene = preload("res://Scenes/Zones/map/map.tscn")
@export var spawn_position: Vector2 = Vector2.ZERO
@export var niveau_termine : String = ""  # <-- chemin du niveau à marquer comme terminé
@export var final_lvl: bool = false

var player_inside = false
var main

func _ready():
	main = get_tree().root.get_node("Main")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	main.position_courante = spawn_position

func _process(_delta):
	if player_inside and Input.is_action_just_pressed("interagir"):
		main.color_locked =false
		# Marque le niveau comme terminé si défini
		if niveau_termine != "":
			main.marquer_niveau_complet(niveau_termine)

		# Change la scène et place le joueur
		if final_lvl:
			show_credits()
			get_tree().paused = true
			return
		var target_pos = global_position if spawn_position == Vector2.ZERO else spawn_position
		main.scene_courante = "res://Scenes/Zones/map/map.tscn"
		main.call_deferred("change_scene", next_scene, target_pos)

func _on_body_entered(body):
	if body.name == "Player":
		player_inside = true

func _on_body_exited(body):
	if body.name == "Player":
		player_inside = false
		
func show_credits():
	var credits_nodes = get_tree().get_nodes_in_group("credits")
	
	for c in credits_nodes:
		if c.has_method("start_credits"):
			c.start_credits()
