extends Control

@onready var fullScreenControl = $HBoxContainer/VBoxContainer/FullScreenControl
@onready var master_volume =$HBoxContainer/VBoxContainer/AudioControl3
@onready var music_volume =$HBoxContainer/VBoxContainer/AudioControl
@onready var SFX_volume =$HBoxContainer/VBoxContainer/AudioControl2
@onready var auto_dialog_control = $HBoxContainer/VBoxContainer/AutoDialogControl


var main

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main = get_tree().root.get_node("Main")
	process_mode = Node.PROCESS_MODE_DISABLED
	visible=false
	var video_settings = ConfigFileHandler.load_video_setting()
	fullScreenControl.button_pressed = video_settings.get("fullscreen", false)

	var audio_settings = ConfigFileHandler.load_audio_setting()
	master_volume.value = min(audio_settings.get("Master", 1.0), 1.0)
	music_volume.value = min(audio_settings.get("Music", 1.0), 1.0)
	SFX_volume.value = min(audio_settings.get("SFX", 1.0), 1.0)
	
	# Load auto dialog setting
	var gameplay_settings = ConfigFileHandler.load_gameplay_setting()
	auto_dialog_control.button_pressed = gameplay_settings.get("auto_dialog", true)
	main.option_auto_dialog = auto_dialog_control.button_pressed

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
	pass # Replace with function body.

func _on_auto_dialog_toggled(button_pressed: bool) -> void:
	main.option_auto_dialog = button_pressed
	ConfigFileHandler.save_gameplay_setting("auto_dialog", button_pressed)
