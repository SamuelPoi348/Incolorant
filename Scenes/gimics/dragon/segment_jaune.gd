extends StaticBody2D

@onready var anim = $AnimatedSprite2D
@onready var area_kill = $Area2D
@onready var area_activation = $Area2D2

var can_kill_ok := true
var main
var busy := false
var player_in_zone := false

func _ready():
	area_kill.body_entered.connect(_on_body_entered)

	area_activation.body_entered.connect(_on_activation_entered)
	area_activation.body_exited.connect(_on_activation_exited)

func _process(delta):
	main = get_tree().root.get_node("Main")
	
	if main.couleur_active == "jaune":
		if player_in_zone:
			if Input.is_action_just_pressed("switch_incolorant_mode"):
				toggle_state()


func toggle_state():
	if busy:
		return
	
	busy = true
	

	
	if can_kill_ok:
		anim.play("move")
	else:
		anim.play_backwards("move")
		
		# 🔁 INVERSION STATE
	can_kill_ok = !can_kill_ok
	await anim.animation_finished
	
	busy = false


func _on_body_entered(body):
	if not body.is_in_group("Player"):
		return
	
	if can_kill_ok:
		if body.has_method("die"):
			body.die()
			
			
func _on_activation_entered(body):
	if body.is_in_group("Player"):
		player_in_zone = true

func _on_activation_exited(body):
	if body.is_in_group("Player"):
		player_in_zone = false
		
func is_yellow_active():
	return not can_kill_ok
	
