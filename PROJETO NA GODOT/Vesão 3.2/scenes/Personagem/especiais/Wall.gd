extends Spatial

var wall_hp
var my_type
onready var arame=get_node("StaticBody/BARRICADA DE ARAME FARPADO")
onready var metal=get_node("StaticBody/Barricada de metal")
onready var madeira=get_node("StaticBody/BARRICADA DE MADEIRA")
onready var puraque=get_node("StaticBody/Barricada de puraque")

var hp=[30,30,50,50]

func _ready():
	
	wall_hp=hp[my_type]
	match my_type:
		0:
			madeira.set_visible(true)
		1:
			arame.set_visible(true)
		2:
			metal.set_visible(true)
		3:
			puraque.set_visible(true)

func _process(delta):
	if wall_hp<=0 and Global.get_tree().is_network_server():
		rpc("die")
		
	
remotesync func damage(damage):
	wall_hp-=damage
	print("wall_damage")

func set_type(type):
	my_type=type

remotesync func die():
	get_node("AnimationPlayer").play("Die")
