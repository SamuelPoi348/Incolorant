extends ParallaxBackground

var player

func _ready():
	# Récupère le joueur depuis le groupe
	player = get_tree().get_first_node_in_group("Player_niv")

func _process(delta):
	if player:
		# Suit uniquement l'axe Y
		scroll_offset.y = lerp(scroll_offset.y, player.global_position.y, 5 * delta)
		
		
		# Bloque le X
		scroll_offset.x = player.global_position.x +115
		pass
