extends Spatial

onready var acai=get_node("Turrets/acai")
onready var eletrica=get_node("Turrets/eletrica")
onready var manicoba=get_node("Turrets/Manicoba")
onready var batata=get_node("Turrets/batata")
onready var turrets=get_node("Turrets")
onready var cast=get_node("Turrets/RayCast")
onready var anim=get_node("Animation")
var canos

var my_type
var my_pos=Transform()
var targuet=null
var angle
var rotate_speed=20
var energy=[15,20,25,50]
var firerate=[0.5,0.5,0.5,1]
var turret_range=[50,50,50,50]
var speed=[200,200,200,200]
var damage=[10,20,30,50]

var cooldown
func _ready():

	cooldown=firerate[my_type]
	my_pos=get_global_transform().origin
	canos=[get_node("Turrets/Pos acai"),get_node("Turrets/Pos eletrica"),get_node("Turrets/Pos batata"),get_node("Turrets/Pos manicoba")]
	cast.set_cast_to(Vector3(0,0,turret_range[my_type]*-1) )
	
	if cast.is_colliding(): 
		print("colidiu")
	match my_type:
		0:
			acai.set_visible(true)
		1:
			eletrica.set_visible(true)
		2:
			manicoba.set_visible(true)
		3:
			batata.set_visible(true)

func _physics_process(delta):
	targuet=get_targuet()

	if energy[my_type]<=0:
		anim.play("end")
	else:
		if targuet==null:
			turrets.rotate_object_local(Vector3(0,1,0),delta)
		else:
			var pos_2d=Vector2(global_transform.origin.x,global_transform.origin.z)
			
			var targuet_pos_2d=Vector2(targuet.x,targuet.z*1)
			var dir=pos_2d.direction_to(targuet_pos_2d)
			var rot= atan2(dir.x,dir.y)+deg2rad(180 )
	
	#		#transforma os vetores de movimento em um angulo que será usado para rotação
	#
			var bodyquat=Quat(turrets.global_transform.basis.get_rotation_quat())#quaternion de rotação do personagem
			var rotquat=Quat(0,0,0,0)#quaternion que será usado para rotação
	#
			rotquat.set_euler(Vector3(0,rot,0))#aplicação dos angulos de rotação ao quaternion
			turrets.global_transform.basis= Basis(bodyquat.slerp(rotquat,delta*rotate_speed) ).scaled(scale)#interpolação dos quaternions, fazendo o personagem girar
			
			if cooldown<=0:
				if cast.is_colliding() and Global.is_host():
					rpc("atk")
					cooldown=firerate[my_type]
					energy[my_type]-=1
			else:
				cooldown-=delta

func set_type(type):
	my_type=type

func get_targuet():
	var enemys=Global._get_enemys()
	var targuet
	var targuet_pos
	var distance_to_targuet
	

	if enemys.size()<=0:
		targuet_pos=null
		
	elif enemys.size()==1:
		targuet_pos=enemys[0].get_global_transform().origin
		distance_to_targuet=enemys[0].get_global_transform().origin.distance_to(my_pos)

	else:
		for t in enemys:
			var wr = weakref(t)

			if wr.get_ref():
				if targuet==null:
					
					targuet=t.get_global_transform().origin
					
				targuet_pos=get_bigger_distance(targuet,t.get_global_transform().origin,my_pos)
			
	if targuet_pos!=null:
		if my_pos.distance_to(targuet_pos)>=turret_range[my_type]:
			targuet_pos=null

	return targuet_pos

remotesync func atk():

	var bl=Ress_3D.get_t_bullet(my_type).instance()

	bl.add_collision_exception_with(get_node("StaticBody"))
	add_child(bl)
	bl.set_global_transform(canos[my_type].get_global_transform())
	bl.set_bullet_speed_and_damage(speed[my_type],damage[my_type])

func get_bigger_distance(local1,local2,my_pos):

	if local1.distance_to(my_pos) < local2.distance_to(my_pos):

		return local1

	elif local1.distance_to(my_pos) >= local2.distance_to(my_pos):

		return local2


func _on_Timer_timeout():
	targuet=get_targuet()
