extends Control

@onready var fullScreenControl = $HBoxContainer/VBoxContainer/FullScreenControl
@onready var master_volume =$HBoxContainer/VBoxContainer/AudioControl3
@onready var music_volume =$HBoxContainer/VBoxContainer/AudioControl
@onready var SFX_volume =$HBoxContainer/VBoxContainer/AudioControl2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
	get_tree().root.get_node("Main").go_back()
