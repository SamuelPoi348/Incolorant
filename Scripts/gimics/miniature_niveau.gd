extends Control

@onready var texture_rect1 = $TextureRect
@onready var texture_rect2 = $TextureRect2
@onready var label_niveau = $TextureRect2/Niveau

@onready var colorux1 = $TextureRect2/Colorux1
@onready var colorux2 = $TextureRect2/Colorux2
@onready var colorux3 = $TextureRect2/Colorux3

var icon_normal = preload("res://Sprites/colorux.png")
var icon_dark = preload("res://Sprites/coloruxsombre.png")

func show_preview(nom: String, mini2: Texture, prefixe_niveau: String):
	texture_rect2.texture = mini2
	label_niveau.text = nom

	# Seuls MN-1 et MN-2 n'ont pas de Colorux
	if prefixe_niveau == "MN-1" or prefixe_niveau == "MN-2":
		colorux1.visible = false
		colorux2.visible = false
		colorux3.visible = false
	else:
		colorux1.visible = true
		colorux2.visible = true
		colorux3.visible = true
		update_colorux_icons(prefixe_niveau)

	visible = true


func update_colorux_icons(prefixe_niveau: String):

	var ids = [
		prefixe_niveau + "-C1",
		prefixe_niveau + "-C2",
		prefixe_niveau + "-C3"
	]

	var icons = [colorux1, colorux2, colorux3]

	for i in range(ids.size()):

		if get_tree().root.get_node("Main").colorux_collectes.values().any(func(arr): return ids[i] in arr):
			icons[i].texture = icon_normal
		else:
			icons[i].texture = icon_dark


func hide_preview():
	visible = false
