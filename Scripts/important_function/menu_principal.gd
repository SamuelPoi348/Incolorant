extends Control
@onready var test = preload("res://Scenes/Zones/Volcan_Rouge/VR-2.tscn")
@onready var l1 = preload("res://Scenes/Zones/Plage_Grise/PG-1.tscn")
@onready var FV1 = preload("res://Scenes/Zones/Foret_Verte/FV-2.tscn")
@onready var VR1 = preload("res://Scenes/Zones/Volcan_Rouge/VR-1.tscn")
@onready var MB1 = preload("res://Scenes/Zones/Volcan_Rouge/VR-1.tscn")
@onready var DJ1 = preload("res://Scenes/Zones/Volcan_Rouge/VR-1.tscn")

@onready var option = preload("res://Scenes/ui/option.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_commencer_button_down() -> void:
	await get_tree().create_timer(1).timeout
	get_tree().root.get_node("Main").change_scene(test)


func _on_option_button_down() -> void:
	var option = get_tree().get_first_node_in_group("Option")
	
	if option:
		option.visible = true
		option.process_mode = Node.PROCESS_MODE_ALWAYS
		#visible = false

func _on_quitter_button_down() -> void:
	get_tree().quit()
