extends Area2D

var player_in_range = false
var chef_vert_dialog_active: Array[String] = [
	"Tu dois être le nouveau, celui que le marchand a mentionné s’être réveillé.",
	"Je suis le chef de ce village de la forêt.",
	"Malheureusement, je ne peux pas vraiment te dire qui tu es ni pourquoi tu es là,",
	"mais je peux t’expliquer un peu ce qui se passe sur cette île.",
	"Il y a quatre tribus distinctes : la mienne dans cette forêt,",
	"la bleue dans la montagne, la jaune dans le désert et la rouge dans la terre volcanique.",
	"Les autres tribus pensent que la montagne au milieu de l’île serait l’endroit où se trouve",
	"le dragon endormi, qui aurait été scellé par nos ancêtres, chefs de tribu.",
	"Ils pensent que ce dragon pourrait bientôt se réveiller et certains s’y préparent.",
	"En vue de cette éventualité, les autres tribus sont un peu à cran.",
	"Comme tu le vois, je ne suis plus tout jeune, alors je te donne l’icône verte.",
	"Elle te servira dans ton aventure et je vois que tu es un réceptacle de couleurs multiples,",
	"alors tu pourras changer de couleur à tout moment si tu as plusieurs icônes,",
	"en restant appuyé sur la touche C. Je ne sais pas ce que cela veut dire,",
	"mais c’était dans un des manuscrits de mes ancêtres."
]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
