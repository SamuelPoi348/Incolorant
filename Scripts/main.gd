extends Node

signal color_changed(new_color: String)

@onready var container = $SceneContainer

var scene_stack: Array[PackedScene] = []
var couleur_active: String = ""
var selecting_color := false
var colorux =59;
var icone_rouge =true;
var icone_jaune =true;
var icone_bleu =true;
var icone_vert =true;

var colorux_detector=true
var dash=true
var double_saut=true
var teleporter_to_portail=true
var golden_colorux=false


# Colorux collectés par niveau
var colorux_collectes := {}
var niveau_courant
var position_courante
var scene_courante

# Liste des niveaux complétés
var niveaux_completes: Array[String] = []

# 🔥 Charge automatiquement le menu principal au lancement
func _ready():
# Charger la scène option en arrière-plan
	var option_scene = load("res://Scenes/ui/option.tscn").instantiate()
	add_child(option_scene)

	# Laisser Godot exécuter son _ready()
	await get_tree().process_frame

	# Supprimer la scène option
	option_scene.queue_free()

	# Ensuite charger le menu
	var menu = load("res://Scenes/important_function/Menu_Principal.tscn")
	change_scene(menu)

func change_scene(packed_scene: PackedScene, player_pos: Vector2 = Vector2.ZERO):
	if container.get_child_count() > 0:
		var current = container.get_child(0)
		scene_stack.push_back(load(current.scene_file_path))
		current.queue_free()

	var new_scene = packed_scene.instantiate()
	container.add_child(new_scene)

	# Si c’est la Map et qu’une position est donnée, place le joueur dessus
	if player_pos != Vector2.ZERO:
		# Assure-toi que le joueur s’appelle PlayerMap dans la Map
		if new_scene.has_node("PlayerMap"):
			var player = new_scene.get_node("PlayerMap")
			player.global_position = player_pos

# Marquer un niveau comme terminé
func marquer_niveau_complet(niveau_path: String):
	if niveau_path in niveaux_completes:
		return
	niveaux_completes.append(niveau_path)

func go_back():
	if scene_stack.size() > 0:
		if container.get_child_count() > 0:
			container.get_child(0).queue_free()

		var previous = scene_stack.pop_back()
		container.add_child(previous.instantiate())
		
func add_colorux():
	colorux+= 1
	
func set_selecting_color(active: bool):
	selecting_color = active

func get_selecting_color() -> bool:
	return selecting_color
	
func set_color(new_color: String):
	couleur_active = new_color
	emit_signal("color_changed", new_color)
	
func enregistrer_colorux(niveau: String, id_colorux: String):
	if !colorux_collectes.has(niveau):
		colorux_collectes[niveau] = []
	
	if id_colorux in colorux_collectes[niveau]:
		return
	
	colorux_collectes[niveau].append(id_colorux)
	add_colorux()

func colorux_deja_pris(niveau: String, id_colorux: String) -> bool:
	if !colorux_collectes.has(niveau):
		return false
	return id_colorux in colorux_collectes[niveau]
	
func colorux_niveau_collectes(prefixe_niveau: String) -> Array:
	var result = []
	
	for niveau in colorux_collectes:
		for id in colorux_collectes[niveau]:
			if id.begins_with(prefixe_niveau):
				result.append(id)
	
	return result
