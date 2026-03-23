extends Area2D

@export var next_scene = preload("res://Scenes/Zones/map/map.tscn")
@export var spawn_position: Vector2 = Vector2.ZERO
@export var niveau_termine : String = ""  # <-- chemin du niveau à marquer comme terminé

var player_inside = false
var main

func _ready():
	main = get_tree().root.get_node("Main")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	main.position_courante = spawn_position

func _process(_delta):
	if player_inside and Input.is_action_just_pressed("interagir"):
		# Marque le niveau comme terminé si défini
		if niveau_termine != "":
			main.marquer_niveau_complet(niveau_termine)

		# Change la scène et place le joueur
		var target_pos = global_position if spawn_position == Vector2.ZERO else spawn_position
		main.scene_courante = "res://Scenes/Zones/map/map.tscn"
		main.call_deferred("change_scene", next_scene, target_pos)

func _on_body_entered(body):
	if body.name == "Player":
		player_inside = true

func _on_body_exited(body):
	if body.name == "Player":
		player_inside = false
