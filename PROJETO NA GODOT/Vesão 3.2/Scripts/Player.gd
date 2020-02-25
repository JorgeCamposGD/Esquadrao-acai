extends KinematicBody


const JUMP_FORCE = 30
const GRAVITY = 0.98
const MAX_FALL_SPEED = 30

export (String, "Pistol", "Shotgun","Smg","Sniper")var classe="Pistol"
export (float, 0,1000,10) var dano_melee=15
export (float, 0,5,0.020) var speed_melee=0.5
export (float,1,100) var move_speed =12
export  var classe_status={"Pistol":{"damage":15,"fire_rate":0.4},#pistola
							"Shotgun":{"damage":40,"fire_rate":0.8},#shotgun
							"Smg":{"damage":10,"fire_rate":0.2},#smg
							"Sniper":{"damage":50,"fire_rate":1}#sniper
}

export (int,1,1000,5) var hp_maximo=100
export (int,1,1000,5) var hp_atual=100
onready var bullets={
			"Pistol":preload("res://scenes/Personagem/Balas/bullet pistol.tscn"),
			"Shotgun":preload("res://scenes/Personagem/Balas/bullet shotgun.tscn"),
			"Smg":preload("res://scenes/Personagem/Balas/bullet smg.tscn"),
			"Sniper":preload("res://scenes/Personagem/Balas/bullet sniper.tscn")
			}
onready var Sons={
			"Pistol":preload("res://assets/sounds/Pistola.wav"),
			"Shotgun":preload("res://assets/sounds/Shotgun.wav"),
			"Smg":preload("res://assets/sounds/Smg.wav"),
			"Sniper":preload("res://assets/sounds/Sniper.wav")
			}
onready var body=get_node("Spatial")
onready var especiais={
			"Pistol":get_node("Spatial/Contruct_area/CollisionShape/Spatial/Granead"),
			"Smg":get_node("Spatial/Contruct_area/CollisionShape/Spatial/Turret"),
			"Shotgun":get_node("Spatial/Contruct_area/CollisionShape/Spatial/Wall"),
			"Sniper":get_node("Spatial/Contruct_area/CollisionShape/Spatial/Trap")
			}
onready var hud=get_node("Control")
onready var anim=get_node("Spatial/Contruct_area/livre")
onready var world=get_tree().get_root()
onready var ray_to_obj=get_node("Spatial/Contruct_area/CollisionShape/RayCast")
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
var melee=false
var in_range_colisor=[]
var free=true
var using_special=false



func _ready():
	
	#for x in especiais:
	hp_atual=100
	Global._add_player(self)
	move_speed*=scale.x
	hud.set_hp(hp_maximo,clamp(hp_atual,1,hp_maximo) )
#
func _physics_process(delta):

	if hp_atual<=0:
		#chamar animação
		#return
		pass  
	var move_vec = Vector3()

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
	#cooldown-=delta if cooldown>0 else 0
	if not(up or down or left or right) and hud.get_input_vec()!=Vector2():
		move_vec.x=hud.get_input_vec().x
		move_vec.z=hud.get_input_vec().y
	if Input.is_action_just_pressed("triangle"): #verifica se o botão de seleção foi apertado
		if melee:
			melee=false
		else:
			melee=true
		#chamar animação


	move_vec = move_vec.normalized()
	move_vec *= move_speed#direção de movimento
	move_vec.y = y_speed#gravidade

	if move_vec.z!=0 or move_vec.x!=0:
		get_node("AnimationPlayer").play("ANDANDO")
		#verifica se o Player esta andando
		rot=atan2(move_vec.x*-1,move_vec.z*-1)
		#transforma os vetores de movimento em um angulo que será usado para rotação


		var bodyquat=Quat(body.global_transform.basis.get_rotation_quat())#quaternion de rotação do personagem
		var rotquat=Quat(0,0,0,0)#quaternion que será usado para rotação

		rotquat.set_euler(Vector3(0,rot,0))#aplicação dos angulos de rotação ao quaternion
		body.global_transform.basis= Basis(bodyquat.slerp(rotquat,delta*rotate_speed) ).scaled(scale)#interpolação dos quaternions, fazendo o personagem girar
	else:
		get_node("AnimationPlayer").play("PARADO")
	move_and_slide(move_vec, Vector3(0, 1, 0),true,4)#movimenta o personagem

	var grounded = is_on_floor()
	y_speed -= GRAVITY
	var just_jumped = false
	if grounded and y_speed <= 0:
		y_speed = -0.1
	if y_speed < -MAX_FALL_SPEED:
		y_speed = -MAX_FALL_SPEED

	if Input.is_action_just_pressed("r1"):
		especiais[classe].set_visible(true)
		using_special=true

	if Input.is_action_just_pressed("square"): #verifica se o botão de ataque foi apertado
		if using_special and free:
			print("colocou")
	elif Input.is_action_pressed("square"):
			atack() #chama a função de tiro
	
	if Input.is_action_just_released("r1"):
		using_special=false
		especiais[classe].set_visible(false)
func atack():

	if cooldown<=0:
		cooldown=classe_status[classe].fire_rate

		if melee:
			if body_in_rage.size()>0:
				for enemy in body_in_rage:
					if enemy.has_method("damage"):
						enemy.damage(dano_melee,0)
			#cooldown=melee

		else:
			var cano_pos=get_node("Spatial/Cano da arma/Position3D").global_transform
			var bl=bullets[classe].instance()

			bl.add_collision_exception_with(self)
			bl.set_global_transform(cano_pos)

			world.call_deferred("add_child",bl)

			var bls=get_node("Bullet_sound")
			bls.set_stream(Sons[classe])
			bls._set_playing(true)



func _on_Melee_Range_body_entered(body):
	body_in_rage.append(body)


func _on_Melee_Range_body_exited(body):
	body_in_rage.erase(body)


func get_global_pos():
	return get_global_transform().origin

func damage(dano,type):
	if hp_atual>0:
		match type:
			0: hp_atual-=dano
	hud.set_hp(hp_maximo,clamp(hp_atual,1,hp_maximo) )
	#animation_dmg.play("dmg")

func set_class(id_class):
	match id_class:
		0: classe="Pistol"

		1:classe="Shotgun"

		2:classe="Smg"

		3:classe="Sniper"


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
	print(body_in_rage)
