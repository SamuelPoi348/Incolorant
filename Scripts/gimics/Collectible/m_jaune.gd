extends Area2D

var main
@onready var collision = $CollisionShape2D
@onready var pickup = $PickUpSound

func _ready() -> void:
	pickup.bus = "SFX"
	main = get_tree().root.get_node("Main")
	if main.manuscrit_jaune:
		visible=false
		collision.disabled = true
	pass

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		pickup.play()
		main.manuscrit_jaune = true
		visible=false
		collision.set_deferred("disabled", true)
		await pickup.finished
		if not main.admin:
			main.sauvegarder()
