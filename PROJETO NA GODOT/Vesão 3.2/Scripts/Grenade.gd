extends RigidBody

func _ready():

	add_force(global_transform.basis.z.normalized()*400,Vector3())
	print(get_child_count())
