extends Spatial
export (PackedScene) var mob
export (int,0,30) var maximo_de_ondas=5
export (int,0,30) var inimigos_por_onda=5
export (float,0,300) var segundos_entre_as_ondas=50
export (int,"por tempo","após o fim da ultima") var tipo_de_onda=1
var actual_wave=0
var instanced_enemys=[]
var in_wave=false
var time_to_wave=10

func _ready():
	instace_mob()
func _physics_process(delta):
	if actual_wave<=maximo_de_ondas and not in_wave:
		actual_wave+=1
		in_wave=true
	
	get_node("Timer").start(randi()%10+1) 



	#else:
	#	finish()
	#	return
	
func finish():
	pass
	
func instace_mob():
	var new_m=mob.instance()
	add_child(new_m)
	new_m.set_global_transform(get_global_transform() )
	new_m.set_scale(Vector3(0.15,0.15,0.15))
	new_m._ready()
	instanced_enemys.append(new_m)
	

func _on_Timer_timeout():
	instace_mob()
	
	
