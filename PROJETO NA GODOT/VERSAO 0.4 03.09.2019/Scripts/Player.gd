extends KinematicBody
 
const MOVE_SPEED = 12
const JUMP_FORCE = 30
const GRAVITY = 0.98
const MAX_FALL_SPEED = 30
 
const H_LOOK_SENS = 1.0
const V_LOOK_SENS = 1.0
 

var rot=0
var y_velo = 0
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
	move_vec = move_vec.rotated(Vector3(0, 1, 0), rotation.y)
	move_vec *= MOVE_SPEED
	move_vec.y = y_velo
	
	if move_vec.z!=0 and move_vec.x!=0:
		rot=atan2(move_vec.z,move_vec.x*-1)

	print(rad2deg(rot) )
	body.set_rotation( Vector3(0,rot,0) )
	
	move_and_slide(move_vec, Vector3(0, 1, 0))
   
	var grounded = is_on_floor()
	y_velo -= GRAVITY
	var just_jumped = false
	if grounded and y_velo <= 0:
		y_velo = -0.1
	if y_velo < -MAX_FALL_SPEED:
		y_velo = -MAX_FALL_SPEED
   
	elif grounded:
		if move_vec.x == 0 and move_vec.z == 0:
			body
	