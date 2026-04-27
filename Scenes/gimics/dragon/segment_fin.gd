extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if has_meta("spawn_position"):
		global_position = get_meta("spawn_position")
		remove_meta("spawn_position")
