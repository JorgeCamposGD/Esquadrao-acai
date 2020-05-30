extends Spatial

onready var acai=get_node("acai")
onready var eletrica=get_node("eletrica")
onready var manicoba=get_node("Manicoba")
onready var batata=get_node("batata")
var my_type

func _ready():

	match my_type:
		0:
			acai.set_visible(true)
		1:
			eletrica.set_visible(true)
		2:
			manicoba.set_visible(true)
		3:
			batata.set_visible(true)

func set_type(type):
	my_type=type
