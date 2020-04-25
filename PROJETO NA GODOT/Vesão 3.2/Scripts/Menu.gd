extends Control

onready var online=get_node("Login")
onready var email_login=$Login/Panel2/Login/Email/Email_adress
onready var password_login=$Login/Panel2/Login/Password/Email_password
onready var create_account=$Login/Panel2/Submit/Email2/Create_email
onready var create_password=$Login/Panel2/Submit/Password2/Create_password
onready var confirm_password=$Login/Panel2/Submit/Password3/Create_password
onready var Ip_label=$Play_direct_panel/Panel2/IPV6_Label
onready var play_direct=$Play_direct_panel
onready var nick_name=$Play_direct_panel/Panel2/Nickname
onready var notify_conect=$Play_direct_panel/Panel2/Notify_conect
onready var inserted_ip=$Play_direct_panel/Panel2/insert_ip
onready var lobby_popup=$Lobby_popup
onready var lobby_panel=$Lobby_popup/Lobby_panel
onready var mission_start=$Lobby_popup/Lobby_panel/Start_Game

onready var host_name=$Lobby_popup/Lobby_panel/Host/Host_name
onready var player1_name=$Lobby_popup/Lobby_panel/Player1/player1_name
onready var player2_name=$Lobby_popup/Lobby_panel/Player2/player2_name
onready var player3_name=$Lobby_popup/Lobby_panel/Player3/player3_name

onready var host_class=$Lobby_popup/Lobby_panel/Host/MenuButton
onready var player1_class=$Lobby_popup/Lobby_panel/Player1/MenuButton
onready var player2_class=$Lobby_popup/Lobby_panel/Player2/MenuButton
onready var player3_class=$Lobby_popup/Lobby_panel/Player3/MenuButton

onready var menu0=$Lobby_popup/Lobby_panel/Host/MenuButton
onready var menu1=$Lobby_popup/Lobby_panel/Player1/MenuButton
onready var menu2=$Lobby_popup/Lobby_panel/Player2/MenuButton
onready var menu3=$Lobby_popup/Lobby_panel/Player3/MenuButton

onready var menu_list=[menu0,menu1,menu2,menu3]

onready var select_button=$Lobby_popup/Lobby_panel/stage_select
onready var connect_status=$Play_direct_panel/Panel2/Notify_conect
onready var players_labels=[host_name, player1_name, player2_name, player3_name]
onready var players_classe_btn=[host_class, player1_class, player2_class, player3_class]

var self_info={
	"name":"",
	"classe":null,
	"host":false,
	"id":null
}
var players_info
var network=Network
var peer
var ip
var cena=preload("res://scenes/Maps/Mapa alpha.tscn")
var used_slots={}
var pre_slots={}

func _ready():
	
	var unp=UPNP.new()
	var vas=unp.discover()
	print(vas)
	Network.get_ip()
	Network.connect("ip_recived",self,"_ip_recived")
	Global.connect('players_change', self, 'players_changed')

	Global.get_tree().connect('connected_to_server', self, '_connected_to_server')
	Global.get_tree().connect('connection_failed', self, '_connection_on_server_fail')
	Global.get_tree().connect('server_disconnected', self, '_server_disconnected')

func _on_Play_pressed():

	get_tree().change_scene_to(cena)

func _on_Play_p2p_pressed():
	pass # Replace with function body.
func _on_Play_host_pressed():
	pass
	#get_node("PopupPanel").show()

func _on_Exit_pressed():
	get_tree().quit()
func _on_Return_pressed():
	$Play_direct_panel.hide()
func _on_Play_online_pressed():
	online.show()
func _on_Login_email_pressed():
	if email_login.get_text()!=null and password_login.get_text()!=null:
		network.login(email_login.get_text(),password_login.get_text())
func _on_Login_email2_pressed():
	if create_account.get_text()!="":
		print(create_account.get_text())
		if (create_password.get_text()!="" and confirm_password.get_text()!=""): 
			if create_password.get_text()==confirm_password.get_text():
				
				network.register(create_account.get_text(),create_password.get_text())
			else:
				print("a confirmação é diferente")
				print(create_account.get_text())
				print(confirm_password.get_text())
		else:
			print("coloque uma senha")
	else:
		print("colocar o endereço de email")
func _on_Play_direct_pressed():
	play_direct.show()


func _on_Create_host_pressed():
	self_info["name"]=nick_name.get_text()

	if nick_name.get_text()=="":
		notify_conect.set_text("insert Nick name")
	else:

		
		Global.create_server(self_info)
	lobby_popup.show()
	go_to_lobby()

func _on_Conect_to_host_pressed():

	var ip=inserted_ip.get_text()


	if nick_name.get_text()=="":
		notify_conect.set_text("insert Nick name")

	else:
		self_info["name"]=nick_name.get_text()

		if ip!="" and is_vallid_ip(ip):

			Global.conect_to_server(ip,self_info)
			self_info["name"]=nick_name.get_text()
		else:
			notify_conect.set_text("Insert a valid IP")

	connect_status.set_text("Connecting...")
	


func _on_insert_ip_text_changed(new_text):
	pass
#	match new_text.length():
#		4,9,14,19,24,29:
#			inserted_ip.text+=":"

func is_vallid_ip(ip_string):
	return true


func _on_Button_pressed():
	online.hide()

func go_to_lobby():

	players_info=Global.get_players_info()

	if Global.get_tree().is_network_server():
		host_name.set_text(players_info[1].name)
		host_class.set_disabled(false)
		mission_start.set_disabled(false)
		select_button.set_disabled(false)
	lobby_popup.show()





func _on_Quit_pressed():
	used_slots={}
	lobby_popup.hide()
	Global.disconnect_game()
	for x in players_labels:
		x.set_text("")
	
	connect_status.set_text("")


func players_changed(changes,id,type):

	
	if type=="player_out":
		for key in used_slots:
			if used_slots[key]["id"]==id:
				used_slots.erase(key)
				players_labels[key-1].set_text("")
				pre_slots.erase(id)


	elif type=="player_in":
		

		used_slots[1]=players_info[1]
		pre_slots[1]=players_info[1]
		
		for key in players_info:
			if key==1:
				continue
			else:
				if not(pre_slots.has(key)):

					pre_slots[key]=players_info[key]
					used_slots[used_slots.size()+1]=players_info[key]
				
		for key in used_slots:
			players_labels[key-1].set_text(used_slots[key]["name"])
			if used_slots[key]["id"]==self_info["id"]:
					players_classe_btn[key-1].set_disabled(false)


	elif type=="class_change":
		for x in used_slots:
			if used_slots[x]["classe"]!=null or used_slots[x]["classe"]!=-1:
				menu_list[x-1].set_item_disabled(x,true)
			else:
				menu_list[x-1].set_item_disabled(x,false)

func _connected_to_server():
	go_to_lobby()

func _connection_on_server_fail():
	connect_status.set_text("Connect fail")

func _server_disconnected():
	pass

func _ip_recived(ip_recived):
	ip=ip_recived
	Ip_label.set_text(Ip_label.get_text()+ip)
	print(ip)


func _on_MenuButton_item_selected(id):


	if id==-1 and players_info[get_tree().get_network_unique_id()]["classe"]!=null:
		for key in used_slots:
				if used_slots[key]["id"]==get_tree().get_network_unique_id():
					menu_list[used_slots[key]["classe"]].set_item_disabled(id,false)
	else:
		if players_info[get_tree().get_network_unique_id()]["classe"]!=null:
			for key in used_slots:
				if used_slots[key]["id"]==get_tree().get_network_unique_id():
					menu_list[used_slots[key]["classe"]].set_item_disabled(id,false)
		for key in used_slots:
			if used_slots[key]["id"]==get_tree().get_network_unique_id():
				menu_list[key-1].set_item_disabled(id,true)
				break

		
	Global.set_class(id)


