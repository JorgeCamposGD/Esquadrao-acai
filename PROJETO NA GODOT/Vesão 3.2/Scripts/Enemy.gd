extends KinematicBody
 

const JUMP_FORCE = 30
const GRAVITY = 0.98
const MAX_FALL_SPEED = 30
const H_LOOK_SENS = 1.0
const V_LOOK_SENS = 1.0
export (int,"melee","pistol","shotgun","smg","sniper") var arma_atual=0
export (float, 0,5,0.020) var atack_melee
export (float, 0,5,0.020) var fire_rate_pistol
export (float, 0,5,0.020) var fire_rate_shotgun
export (float, 0,5,0.020) var fire_rate_smg
export (float, 0,5,0.020) var fire_rate_sniper
export (float,1,100) var move_speed =12

export (int,1,1000,10) var hp_atual=100

export (Array,Resource)var Sons



onready var body=get_node("Spatial")
onready var fire_rate=[atack_melee,
					fire_rate_pistol,
					fire_rate_shotgun,
					fire_rate_smg,
					fire_rate_sniper]

var cooldown=0
var rotate_speed=20
var rot=0
var y_speed = 0
var my_pos
var atacking=false
export (int,"closer","minimun_hp")  var type_find
export (bool) var usable=true
var body_in_rage=[]
var my_creator
func _ready():
	set_physics_process(usable)
	move_speed*=scale.x

func _physics_process(delta):
	my_pos=get_global_transform().origin
	if hp_atual<=0:
		die()
		#get_node("AnimationPlayer").play("Die")
		return
	var move_vec = Vector3()

	move_vec=get_targuet(type_find)-my_pos if get_targuet(type_find)!=Vector3() else Vector3()
	
	move_vec = move_vec.normalized()

	move_vec *= move_speed#direção de movimento
	move_vec.y = y_speed#gravidade
	cooldown-=delta if cooldown>0 else 0
	if move_vec.z!=0 or move_vec.x!=0 and not(atacking):
		#get_node("AnimationPlayer").play("ANDANDO")
		#verifica se o Player esta andando
		rot=atan2(move_vec.x*-1,move_vec.z*-1)
		#transforma os vetores de movimento em um angulo que será usado para rotação
		if body.rotation!=Vector3(0,rot,0):

			rot+=deg2rad(-90)#corrige a rotação da animação q algum traste fez errado
			#verifica se a rotação atual é igual ao angulo para o qual ira virar
			var bodyquat=Quat(body.global_transform.basis.get_rotation_quat())#quaternion de rotação do personagem
			var rotquat=Quat(0,0,0,0)#quaternion que será usado para rotação

			rotquat.set_euler(Vector3(0,rot,0))#aplicação dos angulos de rotação ao quaternion
			body.global_transform.basis= Basis(bodyquat.slerp(rotquat,delta*rotate_speed) ).scaled(scale)#interpolação dos quaternions, fazendo o personagem girar
	#else:
		#get_node("AnimationPlayer").play("PARADO")
	move_and_slide(move_vec, Vector3(0, 1, 0),false,4)#movimenta o personagem
	
	atk()
	
	var grounded = is_on_floor()
	y_speed -= GRAVITY
	var just_jumped = false
	if grounded and y_speed <= 0:
		y_speed = -0.1
	if y_speed < -MAX_FALL_SPEED:
		y_speed = -MAX_FALL_SPEED
   

func atk():

	if cooldown<=0:
		cooldown=fire_rate[arma_atual]
		
		if arma_atual==0:
			if body_in_rage.size()>0:
				for enemy in body_in_rage:
					if enemy.has_method("damage"):

						enemy.damage(10,0)




func get_targuet(type):
	var players=Global._get_players()
	var targuet
	var targuet_pos
	var distance_to_targuet
	
	if type==0:
		if players.size()<=0:
			targuet_pos=Vector3()
			
		elif players.size()==1:
			targuet_pos=players[0].get_global_pos()
			distance_to_targuet=players[0].get_global_pos().distance_to(my_pos)
	
		else:
			for t in players:
				if targuet==null:
					
					targuet=t.get_global_pos()
					
				targuet_pos=get_bigger_distance(targuet,t.get_global_pos(),my_pos)

	
	if my_pos.distance_to(targuet_pos)<=5.0:
		targuet_pos=Vector3()
	return targuet_pos


func get_bigger_distance(local1,local2,my_pos):

	if local1.distance_to(my_pos) < local2.distance_to(my_pos):

		return local1

	elif local1.distance_to(my_pos) >= local2.distance_to(my_pos):

		return local2

func damage(dano,type):

	if hp_atual>0:
		match type:
			0: hp_atual-=dano
		#get_node("AnimationPlayer2").play("Dano")

func die():
	my_creator.remove_instance(self)
	queue_free()
func _on_Timer_timeout():

	queue_free()

func set_creator(creator):
	my_creator=creator
#func _on_AreaMelee_body_entered(body):
#	print(body)
#
#
#func _on_Area_body_entered(body):
#	print(body,"out")
#	body_in_rage.append(body)
#	atk()
#
#
#func _on_Area_body_exited(body):
#	print(body,"in")
#	body_in_rage.erase(body)
