extends Control

var main
var slot_to_delete = -1

@onready var btn_start_1 = $HBoxContainer/VBCSave1/BtnStart1
@onready var btn_start_2 = $HBoxContainer/VBCSave2/BtnStart2
@onready var btn_start_3 = $HBoxContainer/VBCSave3/BtnStart3

@onready var btn_delete_1 = $HBoxContainer/VBCSave1/BtnDelete1
@onready var btn_delete_2 = $HBoxContainer/VBCSave2/BtnDelete2
@onready var btn_delete_3 = $HBoxContainer/VBCSave3/BtnDelete3

@onready var clickSound = $Clicksound
@onready var delete_popup = $DeletePopup


func _ready() -> void:
	clickSound.bus = "SFX"
	main = get_tree().root.get_node("Main")

	update_buttons()


func update_buttons():

	if Sauvegarde.save_exists(1):
		btn_start_1.text = "Continuer"
		btn_delete_1.disabled=false
	else:
		btn_start_1.text = "Nouvelle Partie"
		btn_delete_1.disabled=true

	if Sauvegarde.save_exists(2):
		btn_start_2.text = "Continuer"
		btn_delete_2.disabled=false
	else:
		btn_start_2.text = "Nouvelle Partie"
		btn_delete_2.disabled=true

	if Sauvegarde.save_exists(3):
		btn_start_3.text = "Continuer"
		btn_delete_3.disabled=false
	else:
		btn_start_3.text = "Nouvelle Partie"
		btn_delete_3.disabled=true


func start_slot(slot: int):
	clickSound.play()
	main.current_save_slot = slot

	# charge les données
	if not main.admin:
		main.charger()

	# ferme le menu de save
	#visible = false
	#process_mode = Node.PROCESS_MODE_DISABLED

	# lance le jeu
	var menu = get_tree().get_first_node_in_group("MainMenu")

	if menu:
		menu._start()

func ask_delete(slot: int):

	clickSound.play()

	slot_to_delete = slot

	delete_popup.visible = true
	delete_popup.process_mode = Node.PROCESS_MODE_ALWAYS
	
	delete_popup.popup_centered()

func delete_slot(slot: int):

	Sauvegarde.delete_save(slot)

	update_buttons()


# SLOT 1

func _on_btn_start_1_button_down() -> void:
	start_slot(1)


func _on_btn_delete_1_button_down() -> void:
	ask_delete(1)


# SLOT 2

func _on_btn_start_2_button_down() -> void:
	start_slot(2)


func _on_btn_delete_2_button_down() -> void:
	ask_delete(2)


# SLOT 3

func _on_btn_start_3_button_down() -> void:
	start_slot(3)


func _on_btn_delete_3_button_down() -> void:
	ask_delete(3)


# Fermer la fenêtre

func _on_button_button_down() -> void:

	visible = false
	process_mode = Node.PROCESS_MODE_DISABLED


func _on_button_delete_button_down() -> void:

	clickSound.play()

	if slot_to_delete != -1:

		delete_slot(slot_to_delete)

		slot_to_delete = -1

	delete_popup.visible = false
	delete_popup.process_mode = Node.PROCESS_MODE_DISABLED


func _on_button_annuler_button_down() -> void:

	clickSound.play()

	slot_to_delete = -1

	delete_popup.visible = false
	delete_popup.process_mode = Node.PROCESS_MODE_DISABLED
