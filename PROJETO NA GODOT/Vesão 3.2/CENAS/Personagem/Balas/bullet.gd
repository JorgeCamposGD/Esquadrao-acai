extends KinematicBody

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var time_alive=5
var direction = Vector3()

var bullet_speed = 20
var hit=false
export (int,1,100,5)var bullet_dmg=1500


func _physics_process(delta):
	
	if (hit):
		return
	time_alive-=delta
	if (time_alive<0):
		hit=true
		$anim.play("explode")
	var dir=global_transform.basis.z.normalized()
	
	var col = move_and_collide(delta * dir * bullet_speed)
	if (col):
		if (col.collider and col.collider.has_method("damage")):
			col.collider.damage(bullet_dmg,0)
			print("deu dano")
#		$CollisionShape.disabled=true
		$anim.play("explode")
		hit=true
	

func _on_bullet_body_entered():
	print("got into body")

func set_bullet_speed_and_damage(speed,damage):
	self.bullet_speed=speed
	self.bullet_dmg=damage


func _on_Timer_timeout():
	get_node("MeshInstance").visible=true
