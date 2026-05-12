extends Area2D

var player_in_range := false
var has_triggered := true

@onready var anim = $AnimatedSprite2D

var dialogue: Array[String] = [
	"Toi aussi tu fais partie des descendants dragons ?",
	"Surtout le dis à personne ok !"
]

func _ready() -> void:
	# 🔥 50% de chance de passer en mode dark
	if randi() % 10 == 0:
		anim.play("dark_default")
		has_triggered=false
	else:
		anim.play("default")


func _process(delta: float) -> void:
	if DialogManager.is_dialog_active:
		anim.stop()


func _unhandled_input(event):
	if event.is_action_pressed("interagir") and player_in_range and !has_triggered:
		has_triggered = true
		if !DialogManager.is_dialog_active:
			DialogManager.start_dialog(
				global_position + Vector2(50, 50),
				dialogue
			)


func _on_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		player_in_range = true


func _on_body_exited(body: Node2D) -> void:
	if body is PlayerController:
		player_in_range = false
		DialogManager.dialog_lines = []
