extends Node

const MAX_PLAYERS=4
const DEFAULT_PORT=10567
var players=[]
var peer

var players_info={}
var my_info={}

func _ready():

	
	
	

	_get_players() 
	get_tree().connect('network_peer_connected', self, '_peer_connected')
	get_tree().connect('network_peer_disconnected', self, '_peer_disconnected')
	
	get_tree().connect('connected_to_server', self, '_connected_to_server')
	get_tree().connect('connection_failed', self, '_connection_on_server_fail')
	get_tree().connect('server_disconnected', self, '_server_disconnected')



func _get_players():

	if players.size()>0:
		return players

func create_server(player_info):
	players_info={}
	var p_info=player_info
	
	get_tree().set_network_peer(null)
	peer=null
	peer=NetworkedMultiplayerENet.new()
	peer.create_server(DEFAULT_PORT,MAX_PLAYERS)

	p_info["host"]=true
	p_info["id"]=get_tree().set_network_peer(peer)

	players_info[peer.get_unique_id()]=p_info
	my_info=p_info
	print(players_info)



func conect_to_server(ip,player_info):#recebe o id do player e as informações
	players_info={}
	var p_info=player_info
	print("conectedserver")
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
	print("_conecteserver")
	var local_player_id = get_tree().get_network_unique_id()
	players_info[local_player_id]=my_info
	rpc('_send_player_info',local_player_id,my_info)
	print(players_info)

func _peer_disconnected(id):
	print("saiu")
	players_info.erase(id)
	#.erase(id) # Erase player from info.


func _peer_connected(connected_id):
	print("peer")
	var local_player_id=get_tree().get_network_unique_id()
	if not(get_tree().is_network_server()):
		rpc_id(1, '_request_player_info', local_player_id,connected_id)


remote func _request_player_info(request_from_id,player_id):
	print("request_p_info")
	
	if get_tree().is_network_server():
			rpc_id(request_from_id,'_send_player_info',player_id,players_info[player_id])

remote func _request_players(request_from_id):
	if get_tree().is_network_server():
		for peer_id in players_info:
			if (peer_id!= request_from_id):
				rpc_id(request_from_id,'_send_player_info',peer_id,players_info[peer_id])

remote func _send_player_info(id,info):
	#foi
	print("send_players")
	players_info[id]=info
	

func _connected_ok():
	print("conectou")

func _server_disconnected():
	print("cliente saiu")

func _connection_on_server_fail():
	print("erro ao entrar no servidor")


func _on_Timer_timeout():
	if not(players_info.empty()):
		print(players_info)
