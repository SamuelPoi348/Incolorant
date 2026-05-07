extends Control

var main

@onready var buySound = $buySound
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	buySound.bus = "SFX"
	process_mode = Node.PROCESS_MODE_ALWAYS
	main = get_tree().root.get_node("Main")
	visible = false
	if main.dash and main.double_saut and main.colorux_detector and main.teleporter_to_portail:
		$TextureRect2/VBoxContainer/Item5.visible = true
		$TextureRect2/VBoxContainer/Item51.visible = true
	else:
		$TextureRect2/VBoxContainer/Item5.visible = false
		$TextureRect2/VBoxContainer/Item51.visible = false
		
	if main.colorux_detector:
		$TextureRect2/VBoxContainer/Item11/btn_colorux_finder.disabled = true

	if main.dash:
		$TextureRect2/VBoxContainer/Item21/Btn_flame.disabled = true

	if main.double_saut:
		$TextureRect2/VBoxContainer/Item31/btn_fruit.disabled = true

	if main.teleporter_to_portail:
		$TextureRect2/VBoxContainer/Item41/btn_TPTP.disabled = true

	if main.golden_colorux:
		$TextureRect2/VBoxContainer/Item51/btn_golden.disabled = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_button_down() -> void:
	get_tree().paused = false
	visible = false


func _on_btn_colorux_finder_button_down() -> void:
	if main.colorux >= 3:
		main.colorux -= 3
		main.colorux_detector = true
		$TextureRect2/VBoxContainer/Item11/btn_colorux_finder.disabled = true
		_buy_sound()
		if not main.admin:
			main.sauvegarder()


func _on_btn_flame_button_down() -> void:
	if main.colorux >= 9:
		main.colorux -= 9
		main.dash = true
		$TextureRect2/VBoxContainer/Item21/Btn_flame.disabled = true
		_buy_sound()
		if not main.admin:
			main.sauvegarder()


func _on_btn_fruit_button_down() -> void:
	if main.colorux >= 9:
		main.colorux -= 9
		main.double_saut = true
		$TextureRect2/VBoxContainer/Item31/btn_fruit.disabled = true
		_buy_sound()
		if not main.admin:
			main.sauvegarder()


func _on_btn_tptp_button_down() -> void:
	if main.colorux >= 9:
		main.colorux -= 9
		main.teleporter_to_portail = true
		$TextureRect2/VBoxContainer/Item41/btn_TPTP.disabled = true
		_buy_sound()
		if not main.admin:
			main.sauvegarder()


func _on_btn_golden_button_down() -> void:
	if main.colorux >= 9:
		main.colorux -= 9
		main.golden_colorux = true
		$TextureRect2/VBoxContainer/Item51/btn_golden.disabled = true
		_buy_sound()
		if not main.admin:
			main.sauvegarder()
		
func _buy_sound():
	buySound.play()
	await buySound.finished
	pass
