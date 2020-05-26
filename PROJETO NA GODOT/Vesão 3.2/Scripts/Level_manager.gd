extends Spatial

var level_status=null
onready var play_places=get_node("PlayerPos")
onready var world=get_node("World")
var actual_state
var player_in=[]
export(Array,NodePath)var mob_spawn=["Spawn"]

var high_world=false
func _ready():


	if high_world:
		world.set_environment(Ress_3D.get_envir("pc"))



func game_status_change(type):

	if type=="wait_players":
		print("to esperando")
	elif type=="ready":
		if player_in==[]:

			yield(get_tree(), "idle_frame")
			game_status_change(type)
		else:
		
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
