extends Control
@onready var test = preload("res://Scenes/ScenePresentation.tscn")
@onready var l1 = preload("res://Scenes/Zones/Plage_Grise/PG-1.tscn")
@onready var FV1 = preload("res://Scenes/Zones/Foret_Verte/FV-2.tscn")
@onready var VR1 = preload("res://Scenes/Zones/Volcan_Rouge/VR-2.tscn")
@onready var MB1 = preload("res://Scenes/Zones/Mont_Bleu/MB-2.tscn")
@onready var DJ1 = preload("res://Scenes/Zones/Desert_Jaune/DJ-2.tscn")
@onready var MN1 = preload("res://Scenes/Zones/Montagne_Noire/MN-2.tscn")
@onready var map = preload("res://Scenes/Zones/map/map.tscn")

@onready var option = preload("res://Scenes/ui/option.tscn")
@onready var clickSound = $Clicksound
@onready var mainSound = $MainSound
# Called when the node enters the scene tree for the first time.
var main
func _ready() -> void:
	clickSound.bus = "SFX"
	mainSound.bus = "Music"
	mainSound.play()  # 👈 démarre la musique
	main = get_tree().root.get_node("Main")
	main.color_locked = false
	pass # Replace with function body.


func _on_commencer_button_down() -> void:
	clickSound.play()
	var filePage = get_tree().get_first_node_in_group("FilePage")
	
	if filePage:
		filePage.visible = true
		filePage.process_mode = Node.PROCESS_MODE_ALWAYS
	


func _on_option_button_down() -> void:
	clickSound.play()
	var option = get_tree().get_first_node_in_group("Option")
	
	if option:
		option.visible = true
		option.process_mode = Node.PROCESS_MODE_ALWAYS
		#visible = false

func _on_quitter_button_down() -> void:
	mainSound.stop()  # 👈 stop musique menu
	get_tree().quit()
	
func _start() -> void:
	
	mainSound.stop()  # 👈 stop musique menu
	await get_tree().create_timer(1).timeout
	
	if main.admin:
		get_tree().root.get_node("Main").change_scene(DJ1)
	else:
		var l1_path = l1.resource_path

	# 🔥 si le niveau est déjà complété → map
		if main.niveaux_completes.has(l1_path):
			main.call_deferred("change_scene", map, main.position_courante)
			#get_tree().root.get_node("Main").change_scene(map)
		else:
			get_tree().root.get_node("Main").change_scene(l1)
	print("nuget")
	pass
