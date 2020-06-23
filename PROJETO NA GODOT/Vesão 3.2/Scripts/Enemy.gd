extends KinematicBody
 #Okay

const JUMP_FORCE = 30
const GRAVITY = 0.98
const MAX_FALL_SPEED = 30
const H_LOOK_SENS = 1.0
const V_LOOK_SENS = 1.0
var item=preload("res://scenes/itens/drop.tscn")
export (int,"melee","pistol","shotgun","smg","sniper") var arma_atual=0
export (float, 0,5,0.020) var atack_melee=2
export (float, 0,5,0.020) var fire_rate_pistol
export (float, 0,5,0.020) var fire_rate_shotgun
export (float, 0,5,0.020) var fire_rate_smg
export (float, 0,5,0.020) var fire_rate_sniper
export (float,1,100) var move_speed =12

export (int,1,1000,10) var hp_atual=100

export (Array,Resource)var Sons

export (int,"closer","minimun_hp")  var type_find
export (bool) var usable=true

onready var body=get_node("Spatial")
onready var anim=get_node("Spatial/Armature/Skeleton/AnimationPlayer")
onready var fire_rate=[atack_melee,
					fire_rate_pistol,
					fire_rate_shotgun,
					fire_rate_smg,
					fire_rate_sniper]
onready var dmg_anim=get_node("damageAnin")
var cooldown=0
var rotate_speed=20
var rot=0
var y_speed = 0
var my_pos
var atacking=false
var body_in_rage=[]
var my_creator
var status="normal"
var enemy=true
var atk=false
var efects=[]
var on_fire=false
var live=true
onready var sync_node=get_node("Sync")
puppet var p_hp=Vector3()
puppet var ppos=Transform()

func _ready():
	
	
	randomize()
	set_physics_process(usable)
	move_speed*=scale.x

func _physics_process(delta):
	ppos=get_global_transform().origin
	var move_vec = Vector3()

	if get_global_transform().origin.y<=-10:
		die()
		return
	my_pos=get_global_transform().origin
	if hp_atual<=0:
		die()
		#get_node("AnimationPlayer").play("Die")
		return
	if on_fire:
		hp_atual-=10*delta
	

	
		
	move_vec=get_targuet(type_find,enemy)-my_pos if get_targuet(type_find,enemy)!=Vector3() else Vector3()
	
	move_vec = move_vec.normalized()
	
	move_vec *= move_speed#direção de movimento
	move_vec.y = y_speed#gravidade


	cooldown-=delta if cooldown>0 else 0
		
	if efects.has(0):
		move_vec=Vector3()
	if efects.has(1):
		move_vec=Vector3()
	if efects.has(2):
		move_speed=4
	if efects.has(3):
		move_speed=4
		hp_atual-=10*delta
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
		#anim.play("andando")
	#else:
		#anim.stop()
	if atacking:
		move_vec=Vector3()
	move_and_slide(move_vec, Vector3(0, 1, 0),false,4)#movimenta o personagem
	
	atk(delta)
	
	var grounded = is_on_floor()
	y_speed -= GRAVITY
	var just_jumped = false
	if grounded and y_speed <= 0:
		y_speed = -0.1
	if y_speed < -MAX_FALL_SPEED:
		y_speed = -MAX_FALL_SPEED
   

func atk(delta):
	
	if cooldown<=0:
	
		if arma_atual==0 and body_in_rage.size()>0:
			if not(anim.is_playing()):
				anim.play("andando")
			
	else:
		cooldown-=delta

func compleat_atk():
	for enemy in body_in_rage:
		if enemy.has_method("damage"):
			enemy.damage(5,0)
		elif enemy.get_parent().has_method("damage"):
			enemy.get_parent().damage(5)

func return_walk():
	cooldown=fire_rate[0]
	atacking=false
	anim.stop()
func get_targuet(type,enemy):
	var players
	if not(enemy):
		players=Global._get_enemys()
	else:
		players=Global._get_players()
	var targuet
	var targuet_pos
	var distance_to_targuet
	
	if type==0:
		if players.size()<=0:
			targuet_pos=Vector3()
			
		elif players.size()==1:
			targuet_pos=players[0].get_global_transform().origin
			distance_to_targuet=players[0].get_global_transform().origin.distance_to(my_pos)
	
		else:
			for t in players:
				if targuet==null:
					
					targuet=t.get_global_transform().origin
					
				targuet_pos=get_bigger_distance(targuet,t.get_global_transform().origin,my_pos)

	
	if my_pos.distance_to(targuet_pos)<=4.0:
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
			0:
				hp_atual-=dano
				if not(dmg_anim.is_playing()):
					dmg_anim.play("dano")
		#get_node("AnimationPlayer2").play("Dano")
	
func die():
	
	Global.remove_enemy(self)
	my_creator.remove_instance(self)
	if Global.is_host() and live:
		var class_item=randi()% (Global.get_classes().size()+1)
		var type=null
		if class_item!=0:
			class_item=Global.get_classes()[class_item-1]
			type=randi()%4
		else:
			type=0
		live=false
		rpc("drop_item",class_item,type,get_name())
	

remotesync func drop_item(classe,type,newName):
	var textures=Ress_3D.get_item()
	var inst=item.instance()
	get_parent().add_child(inst)
	inst.global_transform.origin=(get_global_transform().origin)
	inst.set_text(textures[classe][type],classe,type)
	inst.set_name(newName)
	queue_free()

func set_creator(creator):
	my_creator=creator

func aply_efect(classe,type,duration):

	var aplied=false
	if classe==4:
		if not(efects.has(type)):
			efects.append(type)
			aplied=true
			get_node("Efect"+str(type) ) .start(duration[type])
	elif classe==1:
		aplied=true
		if type==3:
			hp_atual-=100
		elif type==1:
			hp_atual-=50
		elif type==0:
			hp_atual-=25
		elif type==2:
			on_fire=true
			get_node("Fire").start(duration)

	return aplied

func _on_Area_body_entered(body):
	
	if body.has_method("damage") or body.get_parent().has_method("damage"):
		
		body_in_rage.append(body)
		atacking=true


func _on_Area_body_exited(body):
	body_in_rage.erase(body)


func _on_Fire_timeout():
	on_fire=false


func _on_Efect0_timeout():
	efects.erase(0)


func _on_Efect1_timeout():
	efects.erase(1)


func _on_Efect2_timeout():
	efects.erase(2) # Replace with function body.
	move_speed=12

func _on_Efect3_timeout():
	efects.erase(3)
	move_speed=12


func _on_Sync_timeout():
	if Global.get_tree().is_network_server() and live:
		rset_unreliable("ppos",get_global_transform().origin)
		rset_unreliable("p_hp",p_hp)
	else:
		global_transform.origin=ppos
	sync_node.start(0.3)
