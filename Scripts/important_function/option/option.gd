extends Control

@onready var fullScreenControl = $HBoxContainer/VBoxContainer/FullScreenControl
@onready var master_volume =$HBoxContainer/VBoxContainer/AudioControl3
@onready var music_volume =$HBoxContainer/VBoxContainer/AudioControl
@onready var SFX_volume =$HBoxContainer/VBoxContainer/AudioControl2

@onready var delete_popup = $DeletePopup
@onready var vBoxDelete = $VBoxContainer

var main

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main = get_tree().root.get_node("Main")
	if main.main_menu_open:
		vBoxDelete.visible=true
	else: 
		vBoxDelete.visible=false
	delete_popup.visible =false
	process_mode = Node.PROCESS_MODE_DISABLED
	visible=false
	var video_settings = ConfigFileHandler.load_video_setting()
	fullScreenControl.button_pressed =video_settings.fullscreen
	
	var audio_settings = ConfigFileHandler.load_audio_setting()
	master_volume.value = min(audio_settings.Master, 1.0)
	music_volume.value = min(audio_settings.Music, 1.0)
	SFX_volume.value = min(audio_settings.SFX, 1.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_quitter_button_down() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_DISABLED
	
	var pause = get_tree().get_first_node_in_group("Pause")
	if pause:
		pause.visible = true


func _on_button_button_down() -> void:
	delete_popup.visible =true
	delete_popup.popup_centered()
	pass # Replace with function body.


func _on_button_delete_button_down() -> void:
		delete_popup.hide()
		main.nouvelle_partie()


func _on_button_annuler_button_down() -> void:
	delete_popup.hide()
	delete_popup.visible = false
	pass # Replace with function body.
