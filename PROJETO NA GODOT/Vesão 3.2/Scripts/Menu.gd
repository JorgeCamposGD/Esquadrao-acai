extends Control

var peer
func _ready():
	pass


func _on_Play_pressed():
	if peer==null:
		peer=NetworkedMultiplayerENet.new()
		peer.create_server(8080,32)
		get_tree().set_network_peer(peer)
		print(get_tree().get_network_peer())
func _on_Play_p2p_pressed():
	pass # Replace with function body.


func _on_Play_host_pressed():
	get_node("Panel/PopupPanel").show()


func _on_Exit_pressed():
	get_tree().quit()
