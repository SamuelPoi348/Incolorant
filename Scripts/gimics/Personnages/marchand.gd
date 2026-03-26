extends Node2D

var player_in_range = false
@export var niveau = ""
var merchant_dialog_active: Array[String] =[]
var merchant_dialog1: Array[String] = [
	"Bienvenue, petit !",
	"Tu cherches quelque chose ?",
	"Ou plutôt, qui es-tu ?",
	"Cette île regorge de surprises, je suis sûr que tu en trouveras.",
	"Sinon, si tu trouves des colorux, amène-les-moi et je t'offrirai de sublimes artéfacts.",
	"Qu'est-ce que c'est ? C'est simple, ils ressemblent à l'objet au-dessus de mon sac."
]

var merchant_dialog2: Array[String] = [
	"Salut, petit !",
	"La forêt verte est l'endroit le plus paisible de cette île.",
	"Parle au chef du village, il t'aidera dans ta quête.",
	"Tu veux voir ma marchandise ?"
]

var merchant_dialog3: Array[String] = [
	"Salut, petit !",
	"La montagne bleue est l'endroit le plus froid de la région,",
	"et ça concerne aussi les habitants.",
	"Tu veux voir ma marchandise ?"
]

var merchant_dialog4: Array[String] = [
	"Salut, petit !",
	"Pourquoi je reste en dehors de la ville ?",
	"J'ai peut-être emprunté quelque chose de leurs inventions.",
	"Tu veux voir ma marchandise ?"
]

var merchant_dialog5: Array[String] = [
	"Salut, petit !",
	"Le volcan est en fait une arène.",
	"Sois bien sûr d'être préparé avant d'y entrer.",
	"Tu veux voir ma marchandise ?"
]
func _ready():
	merchant_dialog_active=merchant_dialog1
	if niveau =="plage":
		merchant_dialog_active=merchant_dialog1
	elif niveau =="forêt":
		merchant_dialog_active=merchant_dialog2
	elif niveau == "montagne":
		merchant_dialog_active=merchant_dialog3
	elif niveau == "desert":
		merchant_dialog_active=merchant_dialog4
	elif niveau == "volcan":
		merchant_dialog_active=merchant_dialog5
		
		
func _unhandled_input(event):
	if event.is_action_pressed("interagir") and player_in_range:
		if !DialogManager.is_dialog_active:
			DialogManager.start_dialog(global_position + Vector2(50,50), merchant_dialog_active)


func _on_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		player_in_range = true
	else: 
		player_in_range = false
		DialogManager.dialog_lines= []


func _on_body_exited(body: Node2D) -> void:
	player_in_range = false
	DialogManager.dialog_lines= []
