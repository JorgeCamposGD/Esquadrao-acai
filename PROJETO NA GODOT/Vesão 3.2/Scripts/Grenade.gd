extends RigidBody

func _ready():
	print(self.translation)
	add_force(self.global_transform.basis.z.normalized()*400,Vector3())
