extends Spatial
export (PackedScene) var mob_resource=preload("res://CENAS/Personagem/Enemy.tscn")
export (int,0,30) var maximo_de_ondas=5
export (int,0,30) var inimigos_por_onda=5
export (float,0,300) var segundos_entre_as_ondas=50
export (int,"por tempo","após o fim da ultima") var tipo_de_onda=1
export (Array,Array,int) var waves
export (Array,NodePath) var spawn_places

var actual_wave=0
var instanced_enemys=[]
var in_wave=false
var time_to_wave=10
var place_index=0
var spawn_points=[]

onready var mob=mob_resource.instance()

func _ready():
	if spawn_places.empty():
		spawn_points=get_children()
	else:
		for x in spawn_places:
			spawn_points.append(get_node(x))
			print("for")
	Engine.target_fps=60
	get_node("Spawn_init/Timer").start(1)
	instace_mob(false) 



	
func instace_mob(persist):
	
	var new_m=mob.duplicate()
	
	if persist:
		
		spawn_points[place_index].add_child(new_m)
		new_m.set_global_transform(spawn_points[randi()%spawn_points.size()-1].get_global_transform() )
		new_m.set_scale(Vector3(0.15,0.15,0.15))
		new_m._ready()
		instanced_enemys.append(new_m)
		get_node("Spawn_init/Timer").start(randi()%5+1) 
	else:
		spawn_points.back().add_child(new_m)
		new_m.set_global_transform(spawn_points.back().get_global_transform() )
		new_m.set_scale(Vector3(0.15,0.15,0.15))
#		new_m.get_node("Spawn_init/Timer").start()
#		new_m.get_node("Spawn_init/Timer").start()
		new_m=get_node("Spawn_init/Timer").start()
		print(new_m)
		
func _on_Timer_timeout():
	instace_mob(true)
	
	
