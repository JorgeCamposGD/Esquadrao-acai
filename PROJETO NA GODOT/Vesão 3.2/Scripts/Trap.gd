extends Area

onready var chop=get_node("CaixadeChop")
onready var farinha=get_node("FarinhaDeGranola")
onready var paraliza=get_node("paralize")
onready var manga=get_node("Mangas")
onready var anim=get_node("AnimationPlayer")
var my_type
var duration=[3,4,5,6]
var active=false
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
	if body.has_method("aply_efect"):
		if body.aply_efect(4,my_type,duration) and not(active):
			get_node("Timer").start(duration[my_type])
			if my_type==0:
				set_deferred("monitoring",false)

func die():
	anim.play("die")

func _on_Timer_timeout():
	die()
