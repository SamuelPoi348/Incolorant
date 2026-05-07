extends Node

var config = ConfigFile.new()
const SETTINGS_FILE_PATH = "user://setting.ini"
# Called when the node enters the scene tree for the first time.
func _ready():
	if !FileAccess.file_exists(SETTINGS_FILE_PATH):
		config.set_value("keybinding","jump","W")
		config.set_value("keybinding","move_right","D")
		config.set_value("keybinding","move_left","A")
		config.set_value("keybinding","move_down","S")
		config.set_value("keybinding","shoot","R")
		config.set_value("keybinding","switch_incolorant_mode","T")
		config.set_value("keybinding","color_select","C")
		config.set_value("keybinding","pause","Escape")
		config.set_value("keybinding","interagir","E")
		config.set_value("keybinding","inventaire","Tab")
		
		config.set_value("video","fullscreen",false)
		
		config.set_value("audio","Master",1.0)
		config.set_value("audio","Music",1.0)
		config.set_value("audio","SFX",1.0)
		
		config.set_value("gameplay","auto_dialog",true)
		
		config.save(SETTINGS_FILE_PATH)
	else:
		config.load(SETTINGS_FILE_PATH)
		
func save_video_setting(key :String, value):
	config.set_value("video",key,value)
	config.save(SETTINGS_FILE_PATH)
		
func load_video_setting():
	var video_settings = {}
	for key in config.get_section_keys("video"):
		video_settings[key] = config.get_value("video",key)
	return video_settings
	
func save_audio_setting(key: String, value):
	config.set_value("audio", key, value)
	config.save(SETTINGS_FILE_PATH)
	
func load_audio_setting():
	var audio_settings = {}
	for key in config.get_section_keys("audio"):
		audio_settings[key] = config.get_value("audio",key)
	return audio_settings
	
func save_keybinding(action: StringName, event: InputEvent):
	var event_str
	if event is InputEventKey:
		event_str = OS.get_keycode_string(event.physical_keycode)
	elif event is InputEventMouseButton:
		event_str = "mouse_" + str(event.button_index)
	
	config.set_value("keybinding",action,event_str)
	config.save(SETTINGS_FILE_PATH)
	
func load_keybindings():
	var keybindings = {}
	var keys = config.get_section_keys("keybinding")
	for key in keys:
		var input_event
		var event_str = config.get_value("keybinding",key)
		
		if event_str.contains("mouse_"):
			input_event = InputEventMouseButton.new()
			input_event.button_index = int(event_str.split("_")[1])
		else:
			input_event = InputEventKey.new()
			input_event.keycode = OS.find_keycode_from_string(event_str)
			
		keybindings[key] = input_event
	return keybindings

func save_gameplay_setting(key: String, value):
	config.set_value("gameplay", key, value)
	config.save(SETTINGS_FILE_PATH)

func load_gameplay_setting():
	var gameplay_settings = {}
	for key in config.get_section_keys("gameplay"):
		gameplay_settings[key] = config.get_value("gameplay", key)
	return gameplay_settings
