extends KinematicBody
#okay
class_name player
var imortal=false

const JUMP_FORCE = 30
const GRAVITY = 0.98
const MAX_FALL_SPEED = 30

export (String, "Pistol", "Shotgun","Smg","Sniper")var classe="Pistol"

export (float, 0,1000,10) var dano_melee=15
export (float, 0,5,0.020) var speed_melee=0.5
export (float,1,100) var move_speed =12
export (int,1,1000,5) var hp_maximo=100
export (int,1,1000,5) var hp_atual=100


export  var classe_status={"Pistol":{"damage":25,"fire_rate":0.4,"ammo_initial":80},#pistola
							"Shotgun":{"damage":40,"fire_rate":0.8,"ammo_initial":50},#shotgun
							"Smg":{"damage":20,"fire_rate":0.2,"ammo_initial":100},#smg
							"Sniper":{"damage":100,"fire_rate":1,"ammo_initial":20}#sniper
							}

onready var body=get_node("Char")
onready var especiais={
			"Pistol":get_node("Char/Contruct_area/CollisionShape/Spatial/Granead"),
			"Smg":get_node("Char/Contruct_area/CollisionShape/Spatial/Turret"),
			"Shotgun":get_node("Char/Contruct_area/CollisionShape/Spatial/Wall"),
			"Sniper":get_node("Char/Contruct_area/CollisionShape/Spatial/Trap")
			}
			

onready var Sons=Ress_3D.get_sound(classe)
onready var camera=$Cam

onready var anim=get_node("Char/Contruct_area/livre")
onready var world=get_tree().get_root()
onready var ray_to_obj=get_node("Char/RayCast")
onready var anim_control=get_node("Char/Armature/"+classe+"/AnimationPlayer")
var resources={0:10,
				1:10,
				2:10,
				3:10
				}
var hud
var cooldown=0
var rotate_speed=25
var rot=0
var y_speed = 0
var up
var down
var left
var right
var btn=Vector2(0,0)
var body_in_rage=[]
var in_range_colisor=[]
var melee=false

var free=true
var constructions=0
var move_state=0
var action_state=0
var peer_id=null
var off_line=false
var live=true
var anim_name="parado com arma"
var class_n
var lock_cam=false
var ammo=30
var my_status=[hp_atual,ammo,resources]
puppet var puppet_move_vec=Vector3()
puppet var puppet_transform=Transform()
puppet var puppet_lock=false
puppet var puppet_anim="parado com arma"
var finish=false
remote func finish_level():
	finish=true
	if Global.is_master(self):
		hud.set_finish()
	set_physics_process(false)
	get_node("CollisionShape").set_disabled(true)
	rpc("finish_level")
	
func _ready():
	match classe:
		"Pistol":
			class_n=1
		"Shotgun":
			class_n=2
		"Smg":
			class_n=3
		"Sniper":
			class_n=4
	Global.set_cam(get_node("Cam"))
	ammo=classe_status[classe]["ammo_initial"]
	my_status[1]=ammo
	hp_atual=hp_maximo
	Global._add_player(self)
	move_speed*=scale.x
	Global
	
	#Global._add_player(self)
	set_process(false)
	set_physics_process(false)
	hud=get_node("Control")

	if Global.is_master(self):
		
		camera.set_current(true)
		hud.set_hp(hp_maximo,clamp(hp_atual,1,hp_maximo) )
	else:
		hud.queue_free()
	Sons=Ress_3D.get_sound(classe)
	Global.set_my_status(my_status)

func get_resources():
	return resources

func set_my_player():
	get_node("WorldEnvironment").queue_free()
	camera.set_current(true)

func start_game():
	if Global.is_master(self):
		get_node("Control").start()
	puppet_transform=get_global_transform()
	set_process(true)
	set_physics_process(true)
	if Global.players_info.size()==1:
		off_line=true

func set_players_interface(id,infos):
	if id==Global.get_tree().get_network_unique_id():
		get_node("Control").show()
	get_node("Control").set_name(infos[id]["name"])

func _start():

	
	#for x in especiais:
	set_physics_process(false)

	
func _physics_process(delta):
	var dead=0
	var in_game=0
	for x in Global.get_players_info():
		in_game+=1
		if Global.get_players_info()[x]["hp"]<=0:
			dead+=1
	
	if dead==in_game:
		all_dead()
	action_state=0



	var move_vec = Vector3()

	if (Global.is_master(self) or off_line) and live and not finish:

		if hp_atual<=0:
			die()
		up=Input.is_action_pressed("up")
		down= Input.is_action_pressed("down")
		right= Input.is_action_pressed("right")
		left= Input.is_action_pressed("left")
	

		if (up or down) and not(up and down):
			move_vec.z = -1 if up else 1
			btn.y=1 if up else -1
		elif (up and down):
			move_vec.z=btn.y
	
		if (left or right) and not(left and right):
			move_vec.x = -1 if left else 1
			btn.x=1 if left else -1
		elif (left and right):
			move_vec.x=btn.x
	
		if cooldown>0:
			cooldown-=delta
		else:
			cooldown=0
		if hud!=null and Global.is_master(self):
			var wr = weakref(hud)
			if not(up or down or left or right) and hud.get_input_vec()!=Vector2() and wr.get_ref():
				move_vec.x=hud.get_input_vec().x
				move_vec.z=hud.get_input_vec().y
	

		
		rset_unreliable("puppet_transform",get_global_transform())
		rset_unreliable("puppet_move_vec",move_vec)
	else:
		move_vec=puppet_move_vec
		set_global_transform(puppet_transform)
	move_vec = move_vec.normalized()
	move_vec *= move_speed#direção de movimento
	move_vec.y = y_speed#gravidade
	
	var grounded = is_on_floor()
	y_speed -= GRAVITY
	var just_jumped = false
	
	if grounded and y_speed <= 0:
		y_speed = -0.1
	if y_speed < -MAX_FALL_SPEED:
		y_speed = -MAX_FALL_SPEED

	if not(lock_cam):
		if move_vec.z!=0 or move_vec.x!=0:
			move_state=1
			#verifica se o Player esta andando
			rot=atan2(move_vec.z*-1,move_vec.x*1)-deg2rad(90)

			#transforma os vetores de movimento em um angulo que será usado para rotação
	
	
			var bodyquat=Quat(body.global_transform.basis.get_rotation_quat())#quaternion de rotação do personagem
			var rotquat=Quat(0,0,0,0)#quaternion que será usado para rotação
	
			rotquat.set_euler(Vector3(0,rot,0))#aplicação dos angulos de rotação ao quaternion
			body.global_transform.basis= Basis(bodyquat.slerp(rotquat,delta*rotate_speed) ).scaled(scale)#interpolação dos quaternions, fazendo o personagem girar
		else:
			move_state=0
	move_and_slide(move_vec, Vector3(0, 1, 0),true,4)#movimenta o personagem

	if not Global.is_master(self):
		puppet_transform=get_global_transform()



	if (Global.is_master(self) or off_line) and live:

		if Input.is_action_pressed("r1") :
			especiais[classe].set_visible(true)
			
			if free:
				var type
				if Input.is_action_just_pressed("cross"): #verifica se o botão de ataque foi apertado
					type=0
				elif Input.is_action_just_pressed("square"):
					type=1
				elif Input.is_action_just_pressed("triangle"):
					type=2
				elif Input.is_action_just_pressed("circle"):
					type=3
				if type!=null:
					action_state=2
					construct_item(classe,type)

		if Input.is_action_just_released("r1"):
			especiais[classe].set_visible(false)

		if Input.is_action_pressed("square") and not(Input.is_action_pressed("r1")):
				atack() #chama a função de tiro
				action_state=1

		if Input.is_action_just_pressed("circle")and not(Input.is_action_pressed("r1")):
			lock_cam=!lock_cam
			rset("puppet_lock",lock_cam)
	
		if Input.is_action_just_pressed("triangle")and not(Input.is_action_pressed("r1")): #verifica se o botão de seleção foi apertado
			if melee:
				melee=false
			else:
				melee=true
			action_state=3
		



		if action_state==0 and move_state==0:
			if melee:
				anim_name="parado com sandalha"
			else:
				anim_name="parado com arma"
		if action_state==1 and move_state==0:
			if melee:
				anim_name="atacando com a sandalha"
			else:
				anim_name="atirando com arma"
		elif action_state==2:
			anim_name="Crafitando"
		elif action_state==3:
			anim_name="trocando de arma"
		rset("puppet_anim",anim_name)
	else:
		if live:
			lock_cam=puppet_lock
			anim_name=puppet_anim
	if not(anim_control.is_playing() ):
		anim_control.play(anim_name)
		
func all_dead():
	if Global.is_master(self):
		hud.all_dead()
func atack():

	if cooldown<=0:
		cooldown=classe_status[classe].fire_rate
		
		if melee:
			if body_in_rage.size()>0:
				rpc("atk",true,body_in_rage,null,null)
		else:
			var cano_pos=get_node("Char/Cano da arma/Position3D").global_transform

			rpc("atk",false,null,cano_pos,classe)

remotesync func atk(melee,body,cano_pos,type):
		if melee:
			for enemy in body_in_rage:
				if enemy.has_method("damage"):
					enemy.damage(dano_melee,0)

		elif ammo>0:
			ammo-=1
			my_status[1]=ammo
			Global.set_my_status(my_status)
			var bl=Ress_3D.get_bullet(type).instance()

			bl.add_collision_exception_with(self)
			bl.set_global_transform(cano_pos)
			bl.set_bullet_speed_and_damage(200,classe_status[classe]["damage"])

			world.call_deferred("add_child",bl)

			var bls=get_node("Bullet_sound")
			bls.set_stream(Sons)
			bls._set_playing(true)


func get_global_pos():
	return get_global_transform().origin

func damage(dano,type):
	if imortal:
		return
	if Global.is_master(self):
		if hp_atual>0:
			match type:
				0: 
					hp_atual-=dano
					my_status[0]=hp_atual
					
					Global.set_my_status(my_status)
		if Global.is_master(self):
			hud.set_hp(hp_maximo,clamp(hp_atual,1,hp_maximo) )
		#animation_dmg.play("dmg")

func set_class(id_class):
	match id_class:
		0: classe="Pistol"

		1:classe="Shotgun"

		2:classe="Smg"

		3:classe="Sniper"
	get_node("Char/Armature/"+classe).show()


func _on_Contruct_area_body_entered(body):
	in_range_colisor.append(body)
	if not(in_range_colisor.empty()):
		if not(anim.is_playing()):
			anim.play("ocupado")
		free=false



func _on_Contruct_area_body_exited(body):
	
	while in_range_colisor.has(body):
		in_range_colisor.erase(body)
	if in_range_colisor.empty():
		if not(anim.is_playing()):
			anim.play("livre")
		free=true

func construct_item(classe,type):

	if resources[type]>0:
		var graned_place=get_node("Char/Contruct_area/CollisionShape/Spatial/Granead").get_global_transform()
		var item_point=ray_to_obj.get_collision_point()
	
		resources[type]-=1
		if Global.is_master(self):
			hud.set_resources(resources)
		rpc("construct",classe,graned_place,item_point,type,constructions)
		constructions+=1
		#item.scale=scale
remotesync func construct(classe,grenade,point,type,const_n):
	

	var item=Ress_3D.get_special_resource(classe).instance()
	var new_transform=Transform()
	match classe:

		"Pistol":
			new_transform=grenade
		
		_:
			
			
			new_transform.origin=point
			new_transform.basis=body.get_global_transform().basis
	
	item.set_global_transform(new_transform)
	item.set_type(type)
	world.call_deferred("add_child",item)

	item.set_name(item.get_name()+str(const_n))
	

func _on_Melee_body_entered(body):

	body_in_rage.append(body)


func _on_Melee_body_exited(body):
	body_in_rage.erase(body)

func server_out():
	get_tree().paused=true
	if Global.is_master(self):
		hud.disconect()
func die():
	live=false
	#chama animação de morrer
func colect(item,classe_item,type):
	var classe_name
	if classe_item==0:
		ammo+=classe_status[classe]["ammo_initial"]/5
		my_status[1]=ammo
		
		item.colected()
	else:

		match classe_item:
			1:
				classe_name="Pistol"
			2:
				classe_name="Shotgun"
			3:
				classe_name="Smg"
			4:
				classe_name="Sniper"
		if classe_name==classe:
			resources[type]+=1
			
		item.rpc("colected")
	
	my_status[2]=resources
	Global.set_my_status(my_status)
	if Global.is_master(self):
		hud.set_resources(resources)
