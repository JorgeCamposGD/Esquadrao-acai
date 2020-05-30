extends Spatial

export (Array,PackedScene) var mob_resource=[preload("res://scenes/enemys/LoucoDaGranola.tscn")]

export (bool) var active=false

export (int,0,30) var maximo_de_inimigos_no_easy=10
export (int,0,30) var maximo_de_inimigos_no_medium=15
export (int,0,30) var maximo_de_inimigos_no_hard=20
export (int,0,30) var maximo_de_ondas=5
export (int,0,30) var inimigos_por_onda=5

export (int,"por tempo","após o fim da ultima") var tipo_de_onda=1

export (float,0,300) var segundos_entre_as_ondas=50

export (Array,Array,int) var granola_waves=[3,6,9]
export (Array,NodePath) var spawn_places

onready var world=get_tree().get_root()
var actual_wave=0
var instanced_enemys=[]
var in_wave=true
var time_to_wave=10
var place_index=0
var spawn_points=[]
var mob_id=0
var difficulty_limit=10
var difficulty
var state="waiting_start"

func _ready():
	difficulty=Global.get_difficulty() if Global.get_difficulty()!=null else 1
	
	match difficulty:
		0:
			difficulty_limit=maximo_de_inimigos_no_easy
		1:
			difficulty_limit=maximo_de_inimigos_no_medium
		2:
			difficulty_limit=maximo_de_inimigos_no_hard
	randomize()
	if not(active):
		return
	else:
		if spawn_places.empty():
	
			spawn_points=get_children()
	
		else:
			for x in spawn_places:
				spawn_points.append(get_node(x))
	
	#	Engine.target_fps=60
	
		
		instace_mob(false) 

func _process(delta):

	if state=="waiting_start":
		return

func set_active():
	
	active=true
	_ready()
	get_node("Spawn_pos/Start").start()
func instace_mob(persist):
	if active==true and in_wave and instanced_enemys.size()<=difficulty_limit:
		if Global.get_tree().is_network_server():
			var random_point=spawn_points[randi()%spawn_points.size()].get_global_transform()
			get_node("Spawn_pos/Timer").start(randi()%5+1) 
			rpc("_instance_mob",mob_id,random_point)
			

remotesync func _instance_mob(mob_id,point):
	var new_enemy=mob_resource[mob_id].instance()
	get_parent().call_deferred("add_child",new_enemy)
	new_enemy.set_creator(self)
	new_enemy.set_global_transform(point)
	instanced_enemys.append(new_enemy)

func _on_Timer_timeout():

	instace_mob(true)
func remove_instance(enemy):
	instanced_enemys.erase(enemy)

func _on_Start_timeout():
	_ready()
