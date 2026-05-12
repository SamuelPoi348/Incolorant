extends Area2D

var player_in_range = false

@onready var anim = $AnimatedSprite2D

var dialogue_bleu: Array[String] = [

	"Salut cette forêt est super",
	"elle me rappelle celle de Jura",
]

func _process(delta: float) -> void:
	if DialogManager.is_dialog_active:
		anim.play("default")
	else:
		anim.stop()

func _unhandled_input(event):
	if event.is_action_pressed("interagir") and player_in_range:

		if !DialogManager.is_dialog_active:
			DialogManager.start_dialog(
				global_position + Vector2(50, 50),
				dialogue_bleu
			)

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		player_in_range = true

func _on_body_exited(body: Node2D) -> void:
	if body is PlayerController:
		player_in_range = false
		DialogManager.dialog_lines = []
