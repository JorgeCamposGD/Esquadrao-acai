extends RigidBody

onready var coxinha=get_node("Coxinha")
onready var cupuacu=get_node("Cupuacu")
onready var molotov=get_node("Molotov")
onready var patob=get_node("Pato")
onready var detonator=get_node("Timer")
onready var anim=get_node("AnimationPlayer")
var type
var timer=[2,5,0,2.56]
var efecty_time=[0,0,5,0]
onready var music=get_node("Explosion")
var on_area=[]
var aplyed=[]
func _ready():
	
	match type:
		0:
			coxinha.set_visible(true)
			
		1:
			cupuacu.set_visible(true)
			get_node("Area").set_scale(Vector3(1.5,1.5,1.5))
		2:
			molotov.set_visible(true)
			
		3:
			patob.set_visible(true)
			get_node("Area").set_scale(Vector3(3,3,3))
			
	add_force(global_transform.basis.z.normalized()*1800,Vector3())
	set_angular_velocity(global_transform.basis.x*-8)


func set_type(type):
	self.type=type


	print(get_colliding_bodies())

func stop():
	self.set_mode(RigidBody.MODE_STATIC) 
	

func _on_Spatial_body_entered(body):
	call_deferred("set_contact_monitor",false)
	detonator.start(timer[type])
	if type==3:
		music.set_stream(load("res://assets/sounds/Bombas/pato bomba.wav"))
		music.play()
	

func _on_Timer_timeout():
	
	anim.play(str(type))
	get_node("Area").set_monitoring(true)
	if type==2:
		music.set_stream(load("res://assets/sounds/Bombas/Motolov.wav"))
		music.play()





func _on_Area_body_entered(body):
	if body.has_method("aply_efect") and not(aplyed.has(body)) and Global.is_host():
		body.aply_efect(1,type,efecty_time[type])
		aplyed.append(body)


func _on_Spatial_body_exited(body):
	pass # Replace with function body.
