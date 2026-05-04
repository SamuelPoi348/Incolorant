extends Node

signal color_changed(new_color: String)

@onready var container = $SceneContainer
var admin =false


#variable stocker dans le fichier sauvegarde
var niveaux_completes: Array[String] = []

var colorux =0;
var icone_rouge =false;
var icone_jaune =false;
var icone_bleu =false;
var icone_vert =false;

var manuscrit_rouge=false;
var manuscrit_jaune=false;
var manuscrit_bleu =false;
var manuscrit_vert=false;

var colorux_detector=false
var dash=false
var double_saut=false
var teleporter_to_portail=false
var golden_colorux=false

var colorux_collectes := {}
var niveau_courant
var position_courante
var scene_courante

#fin de la section à sauvegarder les variables





#variable utilisable au cour du jeu
var scene_stack: Array[PackedScene] = []
var couleur_active: String = ""
var selecting_color := false
var detector_ok=false
var secret_ending=false
var color_locked = false

# 🔥 Charge automatiquement le menu principal au lancement
func _ready():
	if not admin:
		charger()
		
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
	# Update scene_courante to track the current level
	scene_courante = packed_scene.resource_path
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
	
func reset_game():
	# 🔥 vider le container
	for child in container.get_children():
		child.queue_free()
	
	# 🔥 vider la stack
	scene_stack.clear()
	
	# 🔥 reset variables importantes
	couleur_active = ""
	color_locked = false
	selecting_color = false
	
	#position_courante = Vector2.ZERO
	#scene_courante = ""
	
func sauvegarder():
	var data = {
		"niveaux_completes": niveaux_completes,

		"colorux": colorux,
		"icone_rouge": icone_rouge,
		"icone_jaune": icone_jaune,
		"icone_bleu": icone_bleu,
		"icone_vert": icone_vert,

		"manuscrit_rouge": manuscrit_rouge,
		"manuscrit_jaune": manuscrit_jaune,
		"manuscrit_bleu": manuscrit_bleu,
		"manuscrit_vert": manuscrit_vert,

		"colorux_detector": colorux_detector,
		"dash": dash,
		"double_saut": double_saut,
		"teleporter_to_portail": teleporter_to_portail,
		"golden_colorux": golden_colorux,

		"colorux_collectes": colorux_collectes,

		"niveau_courant": niveau_courant,
		"position_courante": position_courante,
		"scene_courante": scene_courante
	}

	Sauvegarde.save_game(data)
	
func charger():
	var data = Sauvegarde.load_game()
	
	if data.is_empty():
		sauvegarder()
		return
	
	niveaux_completes = data.get("niveaux_completes", [])

	colorux = data.get("colorux", 0)
	icone_rouge = data.get("icone_rouge", false)
	icone_jaune = data.get("icone_jaune", false)
	icone_bleu = data.get("icone_bleu", false)
	icone_vert = data.get("icone_vert", false)

	manuscrit_rouge = data.get("manuscrit_rouge", false)
	manuscrit_jaune = data.get("manuscrit_jaune", false)
	manuscrit_bleu = data.get("manuscrit_bleu", false)
	manuscrit_vert = data.get("manuscrit_vert", false)

	colorux_detector = data.get("colorux_detector", false)
	dash = data.get("dash", false)
	double_saut = data.get("double_saut", false)
	teleporter_to_portail = data.get("teleporter_to_portail", false)
	golden_colorux = data.get("golden_colorux", false)

	colorux_collectes = data.get("colorux_collectes", {})

	niveau_courant = data.get("niveau_courant", "")
	position_courante = data.get("position_courante", Vector2.ZERO)
	scene_courante = data.get("scene_courante", "")
	
