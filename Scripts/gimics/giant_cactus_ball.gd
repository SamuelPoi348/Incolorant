extends Node2D

@export var init_x: int = 550
@export var init_y: int = -500  
@export var tween_duration: float = 70.0  
@export var camera_zoom_out: float = 0.7 
@export var enable_camera_zoom: bool = true  

@onready var ball_tween_start: Area2D = $BallTweenStart
@onready var kill_detect: Area2D = $CactusBallGiant/KillDetect

var tween_active = false

func _ready() -> void:
	global_position = Vector2(init_x, init_y)
	
	ball_tween_start.area_entered.connect(_on_ball_tween_start_entered)
	kill_detect.body_entered.connect(_on_kill_detect_body_entered)

func _process(delta: float) -> void:
	pass

# Triggered when player enters BallTweenStart area
func _on_ball_tween_start_entered(area):
	if tween_active:
		return
	tween_active = true
	start_ball_tween()

func _on_kill_detect_body_entered(body):
	if body.is_in_group("Player") or body.name == "PlayerController":
		if body.has_method("die"):
			body.die()

func start_ball_tween():
	if enable_camera_zoom:
		apply_camera_zoom(camera_zoom_out, tween_duration)
	
	var tween = create_tween()
	
	tween.tween_property(self, "position:y", init_y + 250, 1.0)
	
	tween.set_parallel(true)
	tween.tween_property(self, "position:x", init_x + 1165, tween_duration)
	tween.tween_property($CactusBallGiant, "rotation", 2 * PI, tween_duration)
	
	tween.set_parallel(false)
	tween.tween_property(self, "position:y", 200, 1.0)

func apply_camera_zoom(zoom_level: float, duration: float):
	var player = get_tree().get_first_node_in_group("Player_niv")
	if not player or not player.has_node("Camera2D"):
		return
	
	var camera = player.get_node("Camera2D")
	var original_zoom = camera.zoom
	
	var zoom_tween = create_tween()
	zoom_tween.tween_property(camera, "zoom", Vector2(zoom_level, zoom_level), 0.5)
	
	await get_tree().create_timer(duration - 1.0).timeout
	
	zoom_tween = create_tween()
	zoom_tween.tween_property(camera, "zoom", original_zoom, 0.5)
