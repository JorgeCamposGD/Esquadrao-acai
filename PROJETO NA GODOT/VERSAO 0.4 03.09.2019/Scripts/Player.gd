extends KinematicBody
 
const MOVE_SPEED = 12
const JUMP_FORCE = 30
const GRAVITY = 0.98
const MAX_FALL_SPEED = 30
const H_LOOK_SENS = 1.0
const V_LOOK_SENS = 1.0
 

var rot=0
var y_speed = 0


onready var body=get_node("Spatial")

 
func _physics_process(delta):

	var move_vec = Vector3()
	if Input.is_action_pressed("up"):
		move_vec.z -= 1
	if Input.is_action_pressed("down"):
		move_vec.z += 1
	if Input.is_action_pressed("right"):
		move_vec.x += 1
	if Input.is_action_pressed("left"):
		move_vec.x -= 1
	move_vec = move_vec.normalized()
	
	#move_vec = move_vec.rotated(Vector3(0, 1, 0), rotation.y)

	move_vec *= MOVE_SPEED
	move_vec.y = y_speed
	
	if move_vec.z!=0 or move_vec.x!=0:
		
		rot=atan2(move_vec.x*-1,move_vec.z*-1)
		if body.rotation!=Vector3(0,rot,0):
			var bodyquat=Quat(body.global_transform.basis)
			var rotquat=Quat(0,0,0,0)
			rotquat.set_euler(Vector3(0,rot,0))
			body.global_transform.basis= Basis(bodyquat.slerp(rotquat,delta*10) )

	move_and_slide(move_vec, Vector3(0, 1, 0))
   
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



