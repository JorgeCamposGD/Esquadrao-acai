extends KinematicBody

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var time_alive=5
var direction = Vector3()

const BULLET_VELOCITY = 20
var hit=false

func _physics_process(delta):
	if (hit):
		return
	time_alive-=delta
	if (time_alive<0):
		hit=true
		$anim.play("explode")
	var dir=global_transform.basis.z.normalized()
	
	var col = move_and_collide(delta * dir * BULLET_VELOCITY)
	if (col):
		if (col.collider and col.collider.has_method("hit")):
			col.collider.hit()
		$CollisionShape.disabled=true
		$anim.play("explode")
		hit=true
	

func _on_bullet_body_entered():
	print("got into body")
