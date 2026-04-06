#socle_rouge.gd
extends Node2D

@export var sphere_scene : PackedScene
@export var spawn_offset : Vector2 = Vector2(0, 2)  # Position de la sphère au-dessus du socle

var sphere_active : Node = null

func _ready():
	spawn_sphere()  # Crée la première sphère au lancement

func spawn_sphere():
	# Instancier une nouvelle sphère au-dessus du socle
	if sphere_scene:
		sphere_active = sphere_scene.instantiate()
		sphere_active.global_position =  spawn_offset
		sphere_active.direction = Vector2.ZERO       # Immobile au départ
		sphere_active.ready_to_shoot = false        # Ne bouge pas tant que non tirée

		# Ajouter à la scène de manière différée pour éviter l'erreur
		call_deferred("add_child", sphere_active)

		# Connecter le signal tree_exited pour respawn automatique
		if sphere_active.has_signal("tree_exited"):
			sphere_active.connect("tree_exited", Callable(self, "_on_sphere_removed"))

func lancer_sphere(direction: Vector2):
	# Si une sphère existe, lui donner la direction et la faire bouger
	if sphere_active != null and sphere_active.is_inside_tree():
		sphere_active.direction = direction.normalized()
		sphere_active.ready_to_shoot = true

func _on_sphere_removed():
	# Quand la sphère est détruite, respawn une nouvelle sphère
	sphere_active = null
	spawn_sphere()
