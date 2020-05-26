extends KinematicBody

class_name player

const JUMP_FORCE = 30
const GRAVITY = 0.98
const MAX_FALL_SPEED = 30

export (String, "Pistol", "Shotgun","Smg","Sniper")var classe="Pistol"
export (float, 0,1000,10) var dano_melee=15
export (float, 0,5,0.020) var speed_melee=0.5
export (float,1,100) var move_speed =12
export (int,1,1000,5) var hp_maximo=100
export (int,1,1000,5) var hp_atual=100
export  var classe_status={"Pistol":{"damage":15,"fire_rate":0.4},#pistola
							"Shotgun":{"damage":40,"fire_rate":0.8},#shotgun
							"Smg":{"damage":10,"fire_rate":0.2},#smg
							"Sniper":{"damage":50,"fire_rate":1}#sniper
							}

onready var body=get_node("Char")
onready var especiais={
			"Pistol":get_node("Char/Contruct_area/CollisionShape/Spatial/Granead"),
			"Smg":get_node("Char/Contruct_area/CollisionShape/Spatial/Turret"),
			"Shotgun":get_node("Char/Contruct_area/CollisionShape/Spatial/Wall"),
			"Sniper":get_node("Char/Contruct_area/CollisionShape/Spatial/Trap")
			}
var hud
onready var anim=get_node("Char/Contruct_area/livre")
onready var world=get_tree().get_root()
onready var ray_to_obj=get_node("Char/RayCast")
onready var anim_control=get_node("Char/Armature/"+classe+"/AnimationPlayer")
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
var using_special=false
var move_state=0
var action_state=0
var peer_id=null
var off_line=false

var lock_cam=false

onready var Sons=Ress_3D.get_sound(classe)

onready var camera=$Cam

puppet var puppet_move_vec=Vector3()
puppet var puppet_transform=Transform()


func _ready():
	

	
	hp_atual=hp_maximo
	Global._add_player(self)
	move_speed*=scale.x
	
	
	#Global._add_player(self)
	set_process(false)
	set_physics_process(false)
	hud=get_node("Control")
	if Global.is_master(self):
		
		camera.set_current(true)
		hud.set_hp(hp_maximo,clamp(hp_atual,1,hp_maximo) )
	else:
		hud.queue_free()


func set_my_player():
	get_node("WorldEnvironment").queue_free()
	camera.set_current(true)

func start_game():
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
	set_process(true)

	
func _physics_process(delta):
	
	action_state=0

	if hp_atual<=0:
		die()

	var move_vec = Vector3()

	if Global.is_master(self) or off_line:
		
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
		if hud!=null:
			if not(up or down or left or right) and hud.get_input_vec()!=Vector2():
				move_vec.x=hud.get_input_vec().x
				move_vec.z=hud.get_input_vec().y
	
		if Input.is_action_just_pressed("circle"):
			lock_cam=!lock_cam
			print(lock_cam)
		if Input.is_action_just_pressed("triangle"): #verifica se o botão de seleção foi apertado
			if melee:
				melee=false
			else:
				melee=true
		#chamar animação
		anim_control.play("trocando de arma")
		
		rset("puppet_transform",get_global_transform())
		rset("puppet_move_vec",move_vec)
	else:
		move_vec=puppet_move_vec
		set_global_transform(puppet_transform)
	move_vec = move_vec.normalized()
	move_vec *= move_speed#direção de movimento
	move_vec.y = y_speed#gravidade
	
	if not(lock_cam):
		if move_vec.z!=0 or move_vec.x!=0:
			move_state=1
			#verifica se o Player esta andando
			rot=atan2(move_vec.x*-1,move_vec.z*-1)
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

	var grounded = is_on_floor()
	y_speed -= GRAVITY
	var just_jumped = false
	if grounded and y_speed <= 0:
		y_speed = -0.1
	if y_speed < -MAX_FALL_SPEED:
		y_speed = -MAX_FALL_SPEED

	if Global.is_master(self) or off_line:
		if Input.is_action_pressed("r1") and Input.is_action_pressed("r1"):
			especiais[classe].set_visible(true)
			using_special=true
	
		if Input.is_action_just_pressed("square"): #verifica se o botão de ataque foi apertado
			if using_special and free:
				construct_item(classe)
				action_state=2
		if Input.is_action_pressed("square") and not(Input.is_action_pressed("r1")):
				atack() #chama a função de tiro
				action_state=1
		if Input.is_action_just_released("r1"):
			using_special=false
			especiais[classe].set_visible(false)
		
	if action_state==0 and move_state==0:
		if melee:
			anim_control.play("parado com sandalha")
		else:
			anim_control.play("parado com arma")
	if action_state==1 and move_state==0:
		if melee:
			anim_control.play("atacando com a sandalha")
		else:
			anim_control.play("atirando com arma")
	elif action_state==2:
		anim_control.play("Crafitando")
	elif action_state==3:
		anim_control.play("trocando de arma")
		
	
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

		else:
			var bl=Ress_3D.get_bullet(type).instance()

			bl.add_collision_exception_with(self)


			bl.set_global_transform(cano_pos)

			world.call_deferred("add_child",bl)

			var bls=get_node("Bullet_sound")
			bls.set_stream(Sons)
			bls._set_playing(true)









func get_global_pos():
	return get_global_transform().origin

func damage(dano,type):
	if hp_atual>0:
		match type:
			0: hp_atual-=dano
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

func construct_item(type):
	var graned_place=get_node("Char/Contruct_area/CollisionShape/Spatial/Granead").get_global_transform()
	var item_point=ray_to_obj.get_collision_point()
	var item_transfomr=ray_to_obj.get_collision_point()

	rpc("construct",type,graned_place,item_point,item_transfomr)
	#item.scale=scale
remotesync func construct(type,grenade,point,global_transfor):
	var item=Ress_3D.get_special_resource(type).instance()

	if type=="Pistol":
		item.set_global_transform(grenade)

	else:

		item.transform.origin=point
		var t=Transform()
		t.origin=(global_transfor)
		item.set_global_transform(t)
	
	world.call_deferred("add_child",item)
func _on_Melee_body_entered(body):
	body_in_rage.append(body)


func _on_Melee_body_exited(body):
	body_in_rage.erase(body)

func server_out():
	get_tree().paused=true
	
func die():
	pass
