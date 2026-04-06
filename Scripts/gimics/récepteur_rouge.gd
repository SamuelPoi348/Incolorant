# recepteur_rouge.gd
extends StaticBody2D  # bloque le joueur

@onready var animation_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detector: Area2D = $SphereDetector  # Area2D enfant pour détecter la sphère

func _ready():
	# Animation initiale
	if animation_sprite.sprite_frames.has_animation("Vide"):
		animation_sprite.play("Vide")
		
	# Connecte le signal du detector
	detector.area_entered.connect(_on_sphere_entered)

func _on_sphere_entered(area):
	if area.is_in_group("SphereRouge"):
		if animation_sprite.sprite_frames.has_animation("Remplis"):
			animation_sprite.play("Remplis")


func _on_sphere_detector_area_entered(area: Area2D) -> void:
	if area.is_in_group("SphereRouge"):
		if animation_sprite.sprite_frames.has_animation("Remplis"):
			animation_sprite.play("Remplis")
