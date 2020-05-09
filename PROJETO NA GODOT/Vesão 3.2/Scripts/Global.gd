extends Node

signal players_change 
signal game_status
signal disconnect_from_server
const MAX_PLAYERS=4
const DEFAULT_PORT=8080

onready var stages=[scence_0]

var scence_0="res://scenes/Maps/Mapa alpha.tscn"
var players=[]
var peer

var players_info={}
var my_info={}
var level

var loader
var wait_frames
var time_max = 100 # msec
var current_scene
var actual_game_state="on_menu"

var instanced_players={}

var players_status={}
var all_ready
var offline=true
var ip

onready var animation=$Anim

var upnp
func get_game_state():
	return actual_game_state


func _ready():
	
	upnp=UPNP.new()
	upnp.set_discover_ipv6(true)
 

	offline=Global.offline
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() -1)




	get_tree().set_auto_accept_quit(false)


	_get_players() 
	
	Network.connect("ip_recived",self,"_ip_recived")
	get_tree().connect('network_peer_connected', self, '_peer_connected')
	get_tree().connect('network_peer_disconnected', self, '_peer_disconnected')
	
	get_tree().connect('connected_to_server', self, '_connected_to_server')
	get_tree().connect('connection_failed', self, '_connection_on_server_fail')
	get_tree().connect('server_disconnected', self, '_server_disconnected')




func _process(time):
	if Input.is_action_just_pressed("square"):
		print("atirou")
	if loader == null:
		# no need to process anymore
		set_process(false)
		return
	actual_game_state="loading"
	if wait_frames > 0: # wait for frames to let the "loading" animation show up
		wait_frames -= 1
		return

	var t = OS.get_ticks_msec()
	while OS.get_ticks_msec() < t + time_max: # use "time_max" to control for how long we block this thread

		# poll your loader
		var err = loader.poll()

		if err == ERR_FILE_EOF: # Finished loading.
			var resource = loader.get_resource()
			loader = null
			set_new_scene(resource)
			break
		elif err == OK:
			update_progress()
		else: # error during loading
			  
			loader = null
			break

remotesync func selected_level(level_id):
	var self_id= get_tree().get_network_unique_id()
	loader = ResourceLoader.load_interactive(stages[level_id])
	if loader == null: # check for errors
		  
		return
	set_process(true)

	current_scene.queue_free() # get rid of the old scene

	# start your "loading..." animation
	animation.play("loading")

	wait_frames = 1
func update_progress():
	var progress = float(loader.get_stage()) / loader.get_stage_count()
	# Update your progress bar?
	get_node("CanvasLayer/Control/Progress").set_value(100*progress)

	# ... or update a progress animation?
	var length = animation.get_current_animation_length()

	# Call this on a paused animation. Use "true" as the second argument to force the animation to update.
	animation.seek(progress * length, true)

func set_new_scene(scene_resource):
	
	
	current_scene = scene_resource.instance()
	Ress_3D.ocult()
	get_node("/root").add_child(current_scene)

	connect("game_status",current_scene,"game_status_change")
	connect("disconnect_from_server",current_scene,"server_out")
	place_in_scene()
	get_node("CanvasLayer/Control").hide()

func place_in_scene():
	
	for key in players_info:
		
	
		var avatar=Ress_3D.get_player()
		var instanced=avatar.instance()
		connect("disconnect_from_server",instanced,"server_out")

		instanced.set_name( str(players_info[key]["name"]) )
		instanced.set_network_master(key)
		instanced.set_class(players_info[key]["classe"]-1)
		
		if players_info[key]["id"]==get_tree().get_network_unique_id():
			instanced.set_players_interface(get_tree().get_network_unique_id(),players_info)

		current_scene.add_child(instanced)
		instanced_players[key]={"pos":current_scene.get_node("PlayerPos").set_player_in_pos(),"node":instanced}
		if get_tree().is_network_server():
			rpc("_set_players",key,instanced_players[key]["pos"],instanced_players.size())

remotesync func _set_players(key,place,size):
	try_set_players(key,place,size)
func try_set_players(key,place,size):
	if instanced_players.size()<size:
		yield(get_tree(), "idle_frame")
		try_set_players(key,place,size)
	else:
		var inst=instanced_players[key]["node"]
		inst.set_global_transform(place)
		current_scene.player_in.append(inst)
	print("chegou aqui")

func get_game_status():

	if all_ready==true:
		emit_signal("game_status","ready")
	else:
		emit_signal("game_status","wait_players")
func scene_ready():
	rpc("player_ready",get_tree().get_network_unique_id())

remotesync func player_ready(id):
	
	players_info[id]["status_in_game"]="ready"
	all_ready=true
	for key in players_info:
		if players_info[key]["status_in_game"]!="ready":
			all_ready=false

	if all_ready:
		#setar o jogador como pronto
		emit_signal("game_status","ready")
	else:
		emit_signal("game_status","wait_players")

func _get_players():

	return players
func create_server(player_info):
	print("create host")
	players_info={}
	var p_info=player_info
	
	get_tree().set_network_peer(null)
	peer=null
	peer=NetworkedMultiplayerENet.new()
	peer.create_server(DEFAULT_PORT,MAX_PLAYERS)
	peer.set_bind_ip(ip)

	p_info["host"]=true
	p_info["id"]=1
	get_tree().set_network_peer(peer)

	players_info[peer.get_unique_id()]=p_info
	my_info=p_info
	



func conect_to_server(ip,player_info):#recebe o id do player e as informações
	players_info={}
	var p_info=player_info
	print("try conect server")
	peer=NetworkedMultiplayerENet.new()
	
	if get_tree().get_network_peer()==null:
		peer.create_client(ip,DEFAULT_PORT)

	else:
		
		peer.create_client(ip,DEFAULT_PORT)
	
	get_tree().set_network_peer(peer) 
	p_info["host"]=false
	p_info["id"]=peer.get_unique_id()
	my_info=player_info
	

func _connected_to_server():

	#ao se conectar, chama no servido _send_player_info, com os atributos local player id e my info id


	#ao se conectar ao servidor, o ID solicitado para adicionar ao dicionario de jogadores, ao adicionar a informação do jogador
	#passando como chava o ID, uma chave é criada no dicionario e adiciona a informação do usuario atual no dicionario baseado no ID
	var local_player_id = get_tree().get_network_unique_id()
	players_info[local_player_id]=my_info

	#atraves de rpc, a função _send_player_info, é chamada em todos os peers, 
	#passando o ID do cliente atual para que os outros peers, possam adicionar como chave no dicionario
	# e em seguida a informação do usuario para ser adicionada na chave
	rpc('_send_player_info',local_player_id,my_info)


func _peer_disconnected(id):
	print("saiu")
	players_info.erase(id)
	
	emit_signal("players_change",players_info,id,'player_out')
	#.erase(id) # Erase player from info.



func _peer_connected(connected_id):
	offline=false
#é chamado quando o peer detecta que se conectou a outro peer, recebe o endereço do peer que se conectou a ele como connected_id	print("conect_peer")
	
	if not(get_tree().is_network_server()):
	#verifica se o usuario é o host ou ñ

		var local_player_id=get_tree().get_network_unique_id()
		rpc_id(1, '_request_player_info', local_player_id,connected_id)
		#se o usuario ñ for host, ele vai criar uma variavel para receber o ID de usuario na rede
		#então chama a função _request_player_info via rpc(remote procedure call) passando os atributos
		#local_player_id e connected_id 



remote func _request_player_info(request_from_id,player_id):
	#é chamada pelos clientes e recebe request_from_id, que é o id do peer que fez a chada e player_id
	#que é o ID do peer que o cliente passou para receber informações

	if get_tree().is_network_server():
	#verifica se essa função esta sendo chamada no servidor

			rpc_id(request_from_id,'_send_player_info',player_id,players_info[player_id])
			#se estiver, ela estiver sendo chamada no servidor, ela vai chamar via rpc no peer que 
			#solicitou, a função _send_player_info passando o id do peer que se conectou e suas informações


remote func _send_player_info(id,info):
	#recebe do jogador as informações e o id, em seguida adiciona ao dicionario utilizando o ID como chave
	players_info[id]=info
	emit_signal("players_change",players_info,id,"player_in")



remote func _request_players(request_from_id):
	print("request_players")
	
	#verifica se a instancia é do servidor, então chama em todos os peers a função _send_player_info
	if get_tree().is_network_server():
		for peer_id in players_info:
			if (peer_id!= request_from_id):
				rpc_id(request_from_id,'_send_player_info',peer_id,players_info[peer_id])



func _connected_ok():
	print("conectou")

func _server_disconnected():
	offline=true
	get_tree().paused
	emit_signal("disconnect_from_server")

func _connection_on_server_fail():
	print("erro ao entrar no servidor")




func _add_player(player):
	players.append(player)

func get_players_info():
	return players_info

func disconnect_game():
	peer.close_connection(5)

func set_class(new_class):
	
	players_info[get_tree().get_network_unique_id()]["classe"]=new_class
	rpc("send_class", get_tree().get_network_unique_id(), new_class)
	emit_signal("players_change",players_info,new_class,"change_class")

remote func send_class(id,class_id):
	players_info[id]["classe"]=class_id
	emit_signal("players_change",players_info,id,"change_class")


func set_level(id):
	level=id
	
	rpc("selected_level",id)

func start_the_game(level):
	var selected
	if stages.size()>=(level):
		selected=level
	
	if get_tree().is_network_server():
		rpc("selected_level",selected)



func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		get_tree().quit() 


func is_master(requester):
	if offline:
		return false
	else:
		return requester.is_network_master()

func _ip_recived(revived):
	ip=revived

