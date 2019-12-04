extends KinematicBody
 

const JUMP_FORCE = 30
const GRAVITY = 0.98
const MAX_FALL_SPEED = 30
const H_LOOK_SENS = 1.0
const V_LOOK_SENS = 1.0
export (int,"melee","pistol")var classe=1#,"shotgun","smg","sniper") 
var arma_atual=0
export (float, 0,1000,10) var dano_melee
export (float, 0,1000,10) var dano_pistola
export (float, 0,1000,10) var dano_shotgun
export (float, 0,1000,10) var dano_smg
export (float, 0,1000,10) var dano_sniper

export (float, 0,5,0.020) var atack_melee
export (float, 0,5,0.020) var fire_rate_pistol
export (float, 0,5,0.020) var fire_rate_shotgun
export (float, 0,5,0.020) var fire_rate_smg
export (float, 0,5,0.020) var fire_rate_sniper

export (float,1,100) var move_speed =12

onready var damage=[dano_melee,dano_pistola,dano_shotgun,dano_smg,dano_sniper]
export (int,1,1000,5) var hp_maximo=100
export (int,1,1000,5) var hp_atual=100
export (Array,PackedScene) var nao_mexa_nunca
export (Array,Resource)var Sons
onready var body=get_node("Spatial")
onready var fire_rate=[atack_melee,
					fire_rate_pistol,
					fire_rate_shotgun,
					fire_rate_smg,
					fire_rate_sniper]
onready var hud=get_node("Control")
onready var animation_dmg=get_node("AnimationPlayer2")
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
func _ready():
	hp_atual=100
	Global._add_player(self)
	move_speed*=scale.x
	hud.set_hp(hp_maximo,clamp(hp_atual,1,hp_maximo) )
	for x in nao_mexa_nunca:
		var bl=x.instance()
		add_child(bl)
		bl.translate(Vector3(100,100,100))
		
func _physics_process(delta):

	if hp_atual<=0:
		#chamar animação
		return
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

	cooldown-=delta if cooldown>0 else 0
	if not(up or down or left or right) and hud.get_input_vec()!=Vector2():
		move_vec.x=hud.get_input_vec().x
		move_vec.z=hud.get_input_vec().y
	if Input.is_action_just_pressed("ui_select"):
		if arma_atual==classe:
			arma_atual=0
		elif arma_atual==0:
			arma_atual=classe
	if Input.is_action_pressed("shoot"):
		shoot()


	move_vec = move_vec.normalized()
	move_vec *= move_speed#direção de movimento
	move_vec.y = y_speed#gravidade
	
	if move_vec.z!=0 or move_vec.x!=0:
		get_node("AnimationPlayer").play("ANDANDO")
		#verifica se o Player esta andando
		rot=atan2(move_vec.x*-1,move_vec.z*-1)
		#transforma os vetores de movimento em um angulo que será usado para rotação
		#if body.rotation!=Vector3(0,rot,0):

		rot+=deg2rad(360-90)#corrige a rotação da animação q algum traste fez errado
			#verifica se a rotação atual é igual ao angulo para o qual ira virar
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
   
	elif grounded:
		if move_vec.x == 0 and move_vec.z == 0:
			body

func shoot():

	if cooldown<=0:
		cooldown=fire_rate[classe]
		
		if arma_atual==0:
			if body_in_rage.size()>0:
				for enemy in body_in_rage:
					if enemy.has_method("damage"):
						enemy.damage(damage[classe],0)
			#chamar animação
			
		else:
			var cano_pos=get_node("Spatial/Cano da arma/Position3D").global_transform
			var bullet=nao_mexa_nunca[classe-1].instance()
			bullet.global_transform=cano_pos
			get_parent().get_parent().add_child(bullet,true)
			bullet.add_collision_exception_with(self)
			var bls=get_node("Bullet_sound")
			bls.set_stream(Sons[classe])
			bls._set_playing(true)
			#chamar animação


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
	animation_dmg.play("dmg")

