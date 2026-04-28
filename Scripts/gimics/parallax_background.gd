extends ParallaxBackground


@onready var camera = get_viewport().get_camera_2d()

func _process(delta):
	if camera:
		scroll_offset.y = -camera.global_position.y
