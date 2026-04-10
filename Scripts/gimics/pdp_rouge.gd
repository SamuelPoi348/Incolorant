extends StaticBody2D

@onready var anim = $AnimatedSprite2D
@onready var collision = $CollisionShape2D
@onready var c = $Area2D
var main
func _ready() -> void:
	c.body_entered.connect(_on_c_body_entered)
	

func _on_c_body_entered(body):
	if body is PlayerController:
		anim.play("appuyer")
		
		var niveau = get_tree().get_first_node_in_group("Niveau")
		
		if niveau and niveau.has_method("arreter_timer"):
			niveau.arreter_timer()
			
		main = get_tree().root.get_node("Main")
		if niveau and niveau.has_method("rouge"):
			if main:
				main.set_color("rouge")
	
				for player in get_tree().get_nodes_in_group("Player"):
					if player.has_method("update_color_from_manager"):
						player.update_color_from_manager("rouge")
						main.color_locked = true
