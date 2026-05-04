extends Node2D

var main
var niveaux_completes_ids = []

var zones = {
	"PG": ["PG-1"],
	"MN": ["MN-1", "MN-2"],
	"DJ": ["DJ-1", "DJ-2", "DJ-3"],
	"VR": ["VR-1", "VR-2", "VR-3"],
	"FV": ["FV-1", "FV-2", "FV-3"],
	"MB": ["MB-1", "MB-2", "MB-3"]
}

@onready var music = $ZoneMusic

func _ready():
	music.bus = "Music"
	music.play()
	main = get_tree().root.get_node("Main")
	
	# 🔥 Conversion des chemins → IDs
	for path in main.niveaux_completes:
		niveaux_completes_ids.append(path_to_id(path))
	
	update_all_zones()

func path_to_id(path: String) -> String:
	return path.get_file().replace(".tscn", "")

func update_all_zones():
	for zone_name in zones.keys():
		update_zone(zone_name, zones[zone_name])

func update_zone(zone_name: String, niveaux: Array):
	for i in niveaux.size():
		var niveau_id = niveaux[i]
		
		var level_node = $Niveaux.get_node_or_null(niveau_id)
		if level_node == null:
			continue
		
		var unlocked = false
		
		if i == 0:
			unlocked = true
		else:
			var precedent = niveaux[i - 1]
			
			
			if precedent in niveaux_completes_ids:
				unlocked = true
		
		set_level_state(level_node, unlocked)

func set_level_state(node, unlocked: bool):
	node.visible = unlocked
	node.set_process_input(unlocked)
	
	var collision = node.get_node_or_null("CollisionShape2D")
	if collision:
		collision.disabled = !unlocked
