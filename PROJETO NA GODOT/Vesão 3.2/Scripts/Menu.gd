extends Control

onready var create_account_btn=$Login/Panel2/Submit/Login_email2
onready var login_with_email=$Login/Panel2/Login/Login_with_email
onready var create_account_label=$Login/Panel2/Submit/Create_account
onready var online=get_node("Login")
onready var config_btn=$Panel/Config
onready var Play_online=$Panel/Play_online
onready var Play_direct_btn=get_node("Panel/Play_direct")
onready var exit=$Panel/Exit
onready var play_solo=$Panel/Play_solo
onready var game_name=$Panel/Game_name
onready var email_login=$Login/Panel2/Login/Email/Email_adress
onready var password_login=$Login/Panel2/Login/Password/Email_password
onready var create_account=$Login/Panel2/Submit/Email2/Create_email
onready var create_password=$Login/Panel2/Submit/Password2/Create_password
onready var confirm_password=get_node("Login/Panel2/Submit/Confirm password/Create_password")
onready var confirm_password_text=get_node("Login/Panel2/Submit/Confirm password")
onready var Ip_label=$Play_direct_panel/Panel2/IPV4_Label
onready var play_direct=$Play_direct_panel
onready var nick_name=$Play_direct_panel/Panel2/Nickname
onready var notify_conect=$Play_direct_panel/Panel2/Notify_conect
onready var inserted_ip=$Play_direct_panel/Panel2/insert_ip
onready var lobby_popup=$Lobby_popup
onready var lobby_panel=$Lobby_popup/Lobby_panel
onready var mission_start=$Lobby_popup/Lobby_panel/Start_Game
onready var your_ip=$Play_direct_panel/Panel2/your_ip
onready var host_name=$Lobby_popup/Lobby_panel/Host/Host_name
onready var player1_name=$Lobby_popup/Lobby_panel/Player1/player1_name
onready var player2_name=$Lobby_popup/Lobby_panel/Player2/player2_name
onready var player3_name=$Lobby_popup/Lobby_panel/Player3/player3_name

onready var host_class=$Lobby_popup/Lobby_panel/Host/MenuButton
onready var player1_class=$Lobby_popup/Lobby_panel/Player1/MenuButton
onready var player2_class=$Lobby_popup/Lobby_panel/Player2/MenuButton
onready var player3_class=$Lobby_popup/Lobby_panel/Player3/MenuButton

onready var player_n1=$Lobby_popup/Lobby_panel/Player1/Host_identifier
onready var player_n2=$Lobby_popup/Lobby_panel/Player2/Host_identifier
onready var player_n3=$Lobby_popup/Lobby_panel/Player3/Host_identifier

onready var menu0=$Lobby_popup/Lobby_panel/Host/MenuButton
onready var menu1=$Lobby_popup/Lobby_panel/Player1/MenuButton
onready var menu2=$Lobby_popup/Lobby_panel/Player2/MenuButton
onready var menu3=$Lobby_popup/Lobby_panel/Player3/MenuButton

onready var conect_to_host=$Play_direct_panel/Panel2/Conect_to_host
onready var create_host=$Play_direct_panel/Panel2/Create_host
onready var btn_return1=$Play_direct_panel/Panel2/Return
onready var btn_return2=$Lobby_popup/Lobby_panel/Return
onready var btn_return3=$Login/Panel2/Return
onready var btn_return4=$Config_popup/Config_panel/Return
onready var password1=$Login/Panel2/Submit/Password2
onready var passwort0=$Login/Panel2/Login/Password
onready var menu_list=[menu0,menu1,menu2,menu3]

onready var select_button=$Lobby_popup/Lobby_panel/stage_select
onready var connect_status=$Play_direct_panel/Panel2/Notify_conect
onready var players_labels=[host_name, player1_name, player2_name, player3_name]
onready var players_classe_btn=[host_class, player1_class, player2_class, player3_class]
onready var ip_local_label=$Play_direct_panel/Panel2/IP_local_Label
onready var your_ip_local=$Play_direct_panel/Panel2/your_ip_local
onready var language_label=$Config_popup/Config_panel/Language_label
onready var you_ipv6=$Play_direct_panel/Panel2/Ipv6Label
onready var yout_ipv6_label=$Play_direct_panel/Panel2/your_ipv6
var locals=["pt_BR","en","fr_FR"]
var slots_array=[]
var self_info={
	"name":"",
	"classe":null,
	"host":false,
	"id":null,
	"status_in_game":null
}
var players_info
var network=Network
var peer
var ip
var ip_local
var ipv6

var used_slots={}
var pre_slots={}
var username
var selected=0

func _ready():
	retranslate()
	if OS.has_environment("USERNAME"):
		username = OS.get_environment("USERNAME")
		nick_name.set_text(username)
	Network.get_ip()

	Network.connect("ip_recived",self,"_ip_recived")
	Network.connect("ipv6_recived",self,"_ipv6_recived")
	
	Global.connect('players_change', self, 'players_changed')

	Global.get_tree().connect('connected_to_server', self, '_connected_to_server')
	Global.get_tree().connect('connection_failed', self, '_connection_on_server_fail')
	Global.get_tree().connect('server_disconnected', self, '_server_disconnected')

func _on_Play_pressed():

	Global.start_tutorial()

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
	self_info["id"]=1
	if nick_name.get_text()=="":
		notify_conect.set_text(tr("INSERT_NICK"))
	else:

		
		Global.create_server(self_info)
	lobby_popup.show()
	go_to_lobby()

func _on_Conect_to_host_pressed():

	var ip=inserted_ip.get_text()


	if nick_name.get_text()=="":
		notify_conect.set_text(tr("INSERT_NICK"))

	else:
		self_info["name"]=nick_name.get_text()

		if ip!="" and is_vallid_ip(ip):

			Global.conect_to_server(ip,self_info)
			self_info["name"]=nick_name.get_text()
		else:
			notify_conect.set_text(tr("INVALID_IP"))

	connect_status.set_text(tr("CONNECTING"))
	


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
		select_button.set_disabled(false)
	lobby_popup.show()





func _on_Quit_pressed():
	slots_array.clear()
	lobby_popup.hide()
	Global.disconnect_game()
	for x in players_labels:
		x.set_text("")
	
	connect_status.set_text("")


func players_changed(changes,id,type):
	
	slots_array.clear()
	
	for i in menu_list:
		i.set_disabled(true)

	for key in players_info:
		slots_array.append( players_info[key] )

	slots_array.sort_custom(MySystem, "sort_by_id")

	for index in players_labels:
		index.set_text("")

	for index in slots_array:
		players_labels[slots_array.find(index)].set_text(index["name"])
	
		if index["id"]==get_tree().get_network_unique_id():
			menu_list[slots_array.find(index)].set_disabled(false)

	refres_class() 

func _connected_to_server():
	go_to_lobby()

func _connection_on_server_fail():
	connect_status.set_text(tr("CONNECT_FAIL"))

func _server_disconnected():
	pass

func _ip_recived(ip_recived):
	ip=ip_recived
	Ip_label.set_text(ip)
	ip_local=Global.get_ip_local()
	ip_local_label.set_text( str( ip_local ) )

func _ipv6_recived(ip_recived):
	ipv6=ip_recived
	if ipv6!=ip:
		you_ipv6.set_text(ipv6)
	else:
		yout_ipv6_label.set_text(tr("IPV6 INDISPONIVEL"))

func _on_MenuButton_item_selected(id):
	var to_set=null
	if id<=0:
		players_info[get_tree().get_network_unique_id()]["classe"]=null
	else:
		
		players_info[get_tree().get_network_unique_id()]["classe"]=(id)
		to_set=id


	Global.set_class(to_set)
	refres_class()

func refres_class():
	
	slots_array.clear()

	for key in players_info:
		slots_array.append( players_info[key] )

	slots_array.sort_custom(MySystem, "sort_by_id")

	for i in range (0,slots_array.size()):
		
		for x in range(0,5):
			menu_list[i].set_item_disabled(x,false)
		
	for i in range (0,slots_array.size()):

		for id in range(0,slots_array.size()):
			for x in range(0,5):
				if slots_array[id]["classe"]==x:
					menu_list[i].set_item_disabled(x,true)
	
	if get_tree().is_network_server():
		select_button.set_disabled(true)
		var ready=true
		for index in slots_array:
			if index["classe"]==null:
				ready=false
		select_button.set_disabled(!ready)
		mission_start.set_disabled(!ready)


func _on_stage_select_item_selected(id):
	selected=id


func _on_Start_Game_pressed():
	Global.start_the_game(selected)


func _on_return_config_pressed():
	$Config_popup.hide()


func _on_Config_pressed():
	$Config_popup.show()


func _on_OptionButton_item_selected(id):
	TranslationServer.set_locale(locals[id])
	retranslate()

func retranslate():
	
	Play_online.set_text(tr("CONECT_AND_PLAY"))
	Play_direct_btn.set_text(tr("PLAY_WITHOUT"))
	play_solo.set_text(tr("Play_solo"))
	config_btn.set_text(tr("CONFIG"))
	password_login.set_text( tr("PASSWORD") )
	#create_account.set_text( tr("CREATE_ACCOUNT") )
	your_ip.set_text( tr("YOUR_IP") )
	mission_start.set_text( tr("START_GAME") )
	
	player_n1.set_text( tr("JOGADOR"+" "+str(1) ) )
	player_n2.set_text( tr("JOGADOR"+" "+str(2) ) )
	player_n3.set_text( tr("JOGADOR"+" "+str(3) ) )
	
	menu0.set_text( tr("SELECIONAR CLASSE") )
	menu1.set_text( tr("SELECIONAR CLASSE") )
	menu2.set_text( tr("SELECIONAR CLASSE") )
	menu3.set_text( tr("SELECIONAR CLASSE") )
	
	btn_return1.set_text( tr("RETURN"))
	btn_return2.set_text( tr("RETURN"))
	btn_return3.set_text( tr("RETURN"))
	btn_return4.set_text( tr("RETURN"))
	
	select_button.set_text( tr("SELECT_STAGE") )

	conect_to_host.set_text( tr("CONECT_TO_HOST"))
	create_host.set_text( tr("CREATE_HOST"))
	password1.set_text( tr("PASSWORD"))
	passwort0.set_text( tr("PASSWORD"))
	confirm_password_text.set_text("CONFIRM")
	exit.set_text( tr("EXIT"))
	login_with_email.set_text(tr("Login_with_email"))
	create_account_label.set_text(tr("CREATE_ACCOUNT"))
	create_account_btn.set_text(tr("CREATE_ACCOUNT"))
	language_label.set_text(tr("Language:"))
	your_ip_local
