extends Control

@onready var time = $Timer
@onready var label = $TextureRect/TimerLabel

var timer_actif = false
var temps_precedent = -1

func _ready() -> void:
	visible = false
	time.timeout.connect(_on_timer_timeout)

func _process(delta: float) -> void:
	if timer_actif:
		var temps_restant = int(time.time_left)

		if temps_restant != temps_precedent:
			temps_precedent = temps_restant
			
			label.text = str(temps_restant)


func lancer_timer():
	if not timer_actif:
		timer_actif = true
		time.start()
		visible = true


func arreter_timer():
	if timer_actif:
		visible =false
		timer_actif = false
		time.stop()
		


func _on_timer_timeout():
	if timer_actif: 
		timer_actif = false
		time.stop()
