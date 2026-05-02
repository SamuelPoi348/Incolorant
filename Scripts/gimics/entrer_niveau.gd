extends Area2D

@export var chemin_niveau : String = ""
@export var nom_niveau : String = ""
@export var miniature2 : Texture
@export var prefixe_niveau : String
var player_inside := false
var main
var ui
var anim : AnimatedSprite2D

@onready var enter_niveau = $enter_niveau

func _ready():
	enter_niveau.bus = "SFX"
	main = get_tree().root.get_node("Main")
	ui = get_tree().root.get_node("Main/SceneContainer/Map/CanvasLayer/MiniatureNiveau")
	ui.hide_preview()
	anim = $AnimatedSprite2D  # Assure-toi que c’est l’AnimatedSprite2D sur la pastille

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	# Affiche l’animation “complete” si le niveau est déjà terminé
	_update_animation()

func _update_animation():
	if chemin_niveau in main.niveaux_completes:
			anim.play("complete")
	else:
			anim.play("default")

func _on_body_entered(body):
	if body.name == "PlayerMap":
		player_inside = true
		ui.show_preview(nom_niveau, miniature2, prefixe_niveau)
		_update_animation()  # Optionnel si tu veux mettre à jour à l’entrée

func _on_body_exited(body):
	if body.name == "PlayerMap":
		player_inside = false
		ui.hide_preview()

func _process(_delta):
	if player_inside and Input.is_action_just_pressed("interagir"):
		if chemin_niveau != "":
			enter_niveau.play()
			
			var player = get_tree().get_first_node_in_group("PlayerMap")
			if player:
				player.movement_locked = true
				player.velocity = Vector2.ZERO
			
			await get_tree().create_timer(1.0).timeout
			enter_niveau.stop()
			
			if player:
				player.movement_locked = false
			
			var scene = load(chemin_niveau)
			main.niveau_courant = scene
			main.scene_courante=chemin_niveau
			main.call_deferred("change_scene", scene)
	
