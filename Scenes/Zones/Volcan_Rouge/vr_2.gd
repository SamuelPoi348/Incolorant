extends Node2D

@onready var time = $Timer
@onready var ui_timer = $CanvasLayer/TimerZoneRouge
var timer_actif = false
var temps_precedent = -1

func _ready() -> void:
	time.timeout.connect(_on_timer_timeout)

func _process(delta: float) -> void:
	if timer_actif:
		var temps_restant = int(time.time_left)
		
		if temps_restant != temps_precedent:
			temps_precedent = temps_restant

func lancer_timer():
	if not timer_actif:
		timer_actif = true
		time.start()
		ui_timer.lancer_timer()

func arreter_timer():
	if timer_actif:
		timer_actif = false
		time.stop()
		ui_timer.arreter_timer()

func _on_timer_timeout():
	for joueur in get_tree().get_nodes_in_group("Player"):
		ui_timer._on_timer_timeout()
		joueur.die()
