extends KinematicBody
export (float) var gravidade
var motion=Vector3()
var walkdir
var angle=45
export (int) var speed=1
func _physics_process(delta):
	walkdir=Vector2()
	motion.y=0
	if Input.is_action_pressed("up"):
		walkdir.y=-1
	if Input.is_action_pressed("down"):
		walkdir.y=1
	if Input.is_action_pressed("right"):
		walkdir.x=1
	if Input.is_action_pressed("left"):
		walkdir.x=-1
	if (walkdir.x!=0 or walkdir.y!=0):
		get_node("AnimationPlayer").play("ANDANDO")
	else:
		get_node("AnimationPlayer").play("PARADO")
	print(walkdir)
	motion.y+=delta*gravidade
	walkdir=walkdir.normalized()*speed
	motion=Vector3(walkdir.x,gravidade,walkdir.y)
	motion=move_and_slide(motion,Vector3(0,1,0), 0.05, 4, deg2rad(angle))



