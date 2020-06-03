extends Area

onready var chop=get_node("CaixadeChop")
onready var farinha=get_node("FarinhaDeGranola")
onready var paraliza=get_node("paralize")
onready var manga=get_node("Mangas")
var my_type

func _ready():

	match my_type:
		0:
			paraliza.set_visible(true)
		1:
			manga.set_visible(true)
		2:
			chop.set_visible(true)
		3:
			farinha.set_visible(true)

func set_type(type):
	my_type=type


func _on_Spatial_body_entered(body):
	if body.has_method("on_trap"):
		body.on_trap(my_type)
