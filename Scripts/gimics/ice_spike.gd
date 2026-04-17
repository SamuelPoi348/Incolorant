extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func _on_body_entered(body):
	if body is PlayerController:
		body.die()
