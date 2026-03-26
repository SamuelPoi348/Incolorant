extends MarginContainer

@onready var label = $MarginContainer/Label
@onready var timer = $LetterDisplayTimer

const Max_width = 480

var text = ""
var letter_index = 0

var letter_time=0.03
var space_time=0.06
var punctation_time=0.2

signal finished_displaying()

func _ready():
	#print(label)
	pass
	
func display_text(text_to_display: String):
	text = text_to_display
	letter_index = 0       # reset à chaque ligne
	label.text = ""        # on vide le texte avant
	#can_advance_line = false

	# Positionner la boîte juste au-dessus du marchand
	custom_minimum_size.x = min(size.x, Max_width)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	
	global_position.x -= size.x / 2
	global_position.y -= size.y + 24
	
	_display_letter()       # lancer l'affichage lettre par lettre
	
func _display_letter():
	label.text += text[letter_index]
	
	letter_index += 1
	if letter_index >= text.length():
		finished_displaying.emit()
		return
	
	match text[letter_index]:
		"!",".",",","?":
			timer.start(punctation_time)
		" ":
			timer.start(space_time)
		_:
			timer.start(letter_time)


func _on_letter_display_timer_timeout() -> void:
	_display_letter()
