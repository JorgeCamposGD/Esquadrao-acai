extends Node

var players=[]

func _ready():
	_get_players() 


func _add_player(player):
	players.append(player)

func _get_players():
	if players.size()>0:
		return players
