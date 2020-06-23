extends Spatial

#Okay

onready var play_places=get_node("PlayerPos")
onready var world=get_node("World")

var actual_state
var player_in=[]

export(Array,NodePath)var mob_spawn=["Spawn"]

var high_world=false
var level_status=null
var ready_ship=false
func _ready():

	
	if high_world:
		world.set_environment(Ress_3D.get_envir("pc"))

func _physics_process(delta):
	if Global.get_tempo()<=10 and not(ready_ship):
		iniciar_o_barco()
		ready_ship=true
	elif Global.get_tempo()<=0:
		open_ship()

func iniciar_o_barco():
	get_node("barco/AnimationPlayer").play("Barco_start")

func open_ship():
	pass
func game_status_change(type):
	print("aqui")
	if type=="wait_players":
		print("to esperando")
	elif type=="ready":
		if player_in==[]:

			yield(get_tree(), "idle_frame")
			game_status_change(type)
		else:
			
			get_node("wait_timer").start(5)
		
func _on_wait_timer_timeout():

	for index in player_in:
		index.start_game()

	if Global.get_tree().is_network_server():
		for spawn in mob_spawn:
			get_node(spawn).set_active()






func get_player_in():
	pass

func _on_VisibilityNotifier_camera_entered(camera):
	Global.scene_ready()

func server_out():
	pass


func _on_Area_body_entered(body):
	if body.has_method("finish_level"):
		body.finish_level()



