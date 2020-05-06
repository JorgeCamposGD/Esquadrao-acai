extends Spatial
export (Array,PackedScene) var mob_resource=[preload("res://scenes/enemys/LoucoDaGranola.tscn")]
export (int,0,30) var maximo_de_ondas=5
export (int,0,30) var inimigos_por_onda=5
export (float,0,300) var segundos_entre_as_ondas=50
export (int,"por tempo","após o fim da ultima") var tipo_de_onda=1
export (Array,Array,int) var waves
export (Array,NodePath) var spawn_places
onready var world=get_tree().get_root()
var actual_wave=0
var instanced_enemys=[]
var in_wave=false
var time_to_wave=10
var place_index=0
var spawn_points=[]
var mob_id=0
export (bool) var active=false


func _ready():
	randomize()
	if not(active):
		return
	if spawn_places.empty():

		spawn_points=get_children()
		
	else:
		for x in spawn_places:
			spawn_points.append(get_node(x))

	Engine.target_fps=60
	get_node("Spawn_pos/Timer").start(1)
	instace_mob(false) 


func set_active():
	active=true
	get_node("Spawn_pos/Start").start()
func instace_mob(persist):
	
	if Global.get_tree().is_network_server():
		var random_point=spawn_points[randi()%spawn_points.size()-1].get_global_transform()
		get_node("Spawn_pos/Timer").start(randi()%5+1) 
		rpc("_instance_mob",mob_id,random_point)
remotesync func _instance_mob(mob_id,point):
	var new_enemy=mob_resource[mob_id].instance()
	get_parent().add_child(new_enemy)
	new_enemy.set_global_transform(point)
	instanced_enemys.append(new_enemy)

func _on_Timer_timeout():
	instace_mob(true)


func _on_Start_timeout():
	_ready()
