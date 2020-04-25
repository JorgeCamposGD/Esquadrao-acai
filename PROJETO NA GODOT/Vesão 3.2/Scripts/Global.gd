extends Node

signal players_change 

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

	return players
func create_server(player_info):
	print("create host")
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
	print("saiu do servidor")

func _connection_on_server_fail():
	print("erro ao entrar no servidor")




func _add_player(player):
	players.append(player)

func get_players_info():
	return players_info

func disconnect_game():
	peer.close_connection(5)

func set_class(id):
	if get_tree().is_network_server():
		players_info[1]["classe"]=id
	else:
		players_info[get_tree().get_network_unique_id()]
	rpc("send_class", get_tree().get_network_unique_id(), id)

remote func send_class(id,class_id):
	players_info[id]["classe"]=class_id
	print(players_info)


