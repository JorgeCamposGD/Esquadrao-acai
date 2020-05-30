extends RigidBody

onready var coxinha=get_node("Coxinha")
onready var cupuacu=get_node("Cupuacu")
onready var molotov=get_node("Molotov")
onready var patob=get_node("Pato")
var type
func _ready():
	
	match type:
		0:
			coxinha.set_visible(true)
		1:
			cupuacu.set_visible(true)
		2:
			molotov.set_visible(true)
		3:
			patob.set_visible(true)
	add_force(global_transform.basis.z.normalized()*1800,Vector3())
	set_angular_velocity(global_transform.basis.x*-8)


func set_type(type):
	self.type=type

