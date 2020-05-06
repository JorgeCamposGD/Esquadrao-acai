extends Spatial


onready var pos0=$Position3D
onready var pos1=$Position3D2
onready var pos2=$Position3D3
onready var pos3=$Position3D4
onready var pos=[pos0,pos1,pos2,pos3]
var players_in=0

func set_player_in_pos():
	if Global.get_tree().is_network_server():
		var new_pos=pos[players_in].get_global_transform()
		players_in+=1
		return new_pos

