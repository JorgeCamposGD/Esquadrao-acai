extends Control

onready var create_account_btn=$PanelContainer/Login/Panel2/Submit/Login_email2
onready var login_with_email=$PanelContainer/Login/Panel2/Login/Login_with_email
onready var create_account_label=$PanelContainer/Login/Panel2/Submit/Create_account
onready var online=$PanelContainer/Login
onready var config_btn=$PanelContainer/Panel/Config
onready var Play_online=$PanelContainer/Panel/Play_online
onready var Play_direct_btn=$PanelContainer/Panel/Play_direct
onready var exit=$PanelContainer/Panel/Exit
onready var play_solo=$PanelContainer/Panel/Play_solo
onready var game_name=$PanelContainer/Panel/Game_name
onready var email_login=$PanelContainer/Login/Panel2/Login/Email/Email_adress
onready var password_login=$PanelContainer/Login/Panel2/Login/Password/Email_password
onready var create_account=$PanelContainer/Login/Panel2/Submit/Email2/Create_email
onready var create_password=$PanelContainer/Login/Panel2/Submit/Password2/Create_password
onready var confirm_password=$PanelContainer/Login/Panel2/Submit/Confirm_password/Create_password
onready var confirm_password_text=$PanelContainer/Login/Panel2/Submit/Confirm_password
onready var Ip_label=$PanelContainer/Play_direct_panel/Panel2/IPV4_Label
onready var play_direct=$PanelContainer/Play_direct_panel
onready var nick_name=$PanelContainer/Play_direct_panel/Panel2/Nickname
onready var notify_conect=$PanelContainer/Play_direct_panel/Panel2/Notify_conect
onready var inserted_ip=$PanelContainer/Play_direct_panel/Panel2/insert_ip
onready var lobby_popup=$PanelContainer/Lobby_popup
onready var lobby_panel=$PanelContainer/Lobby_popup/Lobby_panel
onready var mission_start=$PanelContainer/Lobby_popup/Lobby_panel/Start_Game
onready var your_ip=$PanelContainer/Play_direct_panel/Panel2/your_ip
onready var host_name=$PanelContainer/Lobby_popup/Lobby_panel/Host/Host_name
onready var player1_name=$PanelContainer/Lobby_popup/Lobby_panel/Player1/player1_name
onready var player2_name=$PanelContainer/Lobby_popup/Lobby_panel/Player2/player2_name
onready var player3_name=$PanelContainer/Lobby_popup/Lobby_panel/Player3/player3_name

onready var host_class=$PanelContainer/Lobby_popup/Lobby_panel/Host/MenuButton
onready var player1_class=$PanelContainer/Lobby_popup/Lobby_panel/Player1/MenuButton
onready var player2_class=$PanelContainer/Lobby_popup/Lobby_panel/Player2/MenuButton
onready var player3_class=$PanelContainer/Lobby_popup/Lobby_panel/Player3/MenuButton

onready var player_n1=$PanelContainer/Lobby_popup/Lobby_panel/Player1/Host_identifier
onready var player_n2=$PanelContainer/Lobby_popup/Lobby_panel/Player2/Host_identifier
onready var player_n3=$PanelContainer/Lobby_popup/Lobby_panel/Player3/Host_identifier

onready var menu0=$PanelContainer/Lobby_popup/Lobby_panel/Host/MenuButton
onready var menu1=$PanelContainer/Lobby_popup/Lobby_panel/Player1/MenuButton
onready var menu2=$PanelContainer/Lobby_popup/Lobby_panel/Player2/MenuButton
onready var menu3=$PanelContainer/Lobby_popup/Lobby_panel/Player3/MenuButton

onready var conect_to_host=$PanelContainer/Play_direct_panel/Panel2/Conect_to_host
onready var create_host=$PanelContainer/Play_direct_panel/Panel2/Create_host
onready var btn_return1=$PanelContainer/Play_direct_panel/Panel2/Return
onready var btn_return2=$PanelContainer/Lobby_popup/Lobby_panel/Return
onready var btn_return3=$PanelContainer/Login/Panel2/Return
onready var btn_return4=$PanelContainer/Config_popup/Config_panel/Config_list/Return
onready var password1=$PanelContainer/Login/Panel2/Submit/Password2
onready var passwort0=$PanelContainer/Login/Panel2/Login/Password
onready var menu_list=[menu0,menu1,menu2,menu3]

onready var select_button=$PanelContainer/Lobby_popup/Lobby_panel/stage_select
onready var connect_status=$PanelContainer/Play_direct_panel/Panel2/Notify_conect
onready var players_labels=[host_name, player1_name, player2_name, player3_name]
onready var players_classe_btn=[host_class, player1_class, player2_class, player3_class]
onready var ip_local_label=$PanelContainer/Play_direct_panel/Panel2/IP_local_Label
onready var your_ip_local=$PanelContainer/Play_direct_panel/Panel2/your_ip_local
onready var language_label=$PanelContainer/Config_popup/Config_panel/Config_list/Laguage_container/Language_label
onready var you_ipv6=$PanelContainer/Play_direct_panel/Panel2/Ipv6Label
onready var yout_ipv6_label=$PanelContainer/Play_direct_panel/Panel2/your_ipv6
onready var resolution_options=$PanelContainer/Config_popup/Config_panel/Config_list/Resolution/Resolution_options
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
var resolutions=[Vector2(1280,720),Vector2(1366,768),Vector2(1600,900),Vector2(1920,1080),Vector2(2560,1440),Vector2(3840,2160)]
var screen
var in_show=[]
func _ready():
	#OS.set_window_position(Vector2())
	screen=OS.get_screen_size()
	Settings.resolution=screen
	get_node("PanelContainer/Config_popup/Config_panel/Config_list/FullScreen_container/CheckBox").pressed=OS.is_window_fullscreen()
	var ress_native
	for i in resolutions:
		if i.y==screen.y:
			var native_ress=""
			resolution_options.select(resolutions.rfind(i))
			_on_Resolution_options_item_selected(resolutions.rfind(i))
			native_ress+=resolution_options.get_item_text(resolutions.rfind(i))
			native_ress+=tr("Nativa"+str(i))
			
			break
	 
	Global.set_music("res://assets/sounds/musica final.wav")
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

	var tutorial=get_node("PanelContainer/Tutorial")
	to_show(tutorial)


func Exit_pressed():
	get_tree().quit()

func _on_Return_pressed():

	var before_size=in_show.size()
	if in_show.size()>0:
		if in_show.size()>=before_size:

			in_show.back().hide()
			in_show.erase(in_show.back())
			yield(get_tree(), "idle_frame")




func _on_Play_online_pressed():
	
	to_show(online)

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
	to_show(play_direct)

func _on_Create_host_pressed():
	self_info["name"]=nick_name.get_text()
	self_info["id"]=1
	if nick_name.get_text()=="":
		notify_conect.set_text(tr("INSERT_NICK"))
	else:

		
		Global.create_server(self_info)
	to_show(lobby_popup)
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
	to_show(lobby_popup)





func _on_Quit_pressed():
	slots_array.clear()
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

func _on_Config_pressed():
	to_show($PanelContainer/Config_popup)

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


func _on_Play_solo3_pressed():
	get_node("PanelContainer/Tutorial").hide()


func _on_Resolution_options_item_selected(id):
	Settings.set_resolution(id)
	get_node("PanelContainer")._set_size(resolutions[id]+Vector2(14,14))
	print_debug(OS.get_screen_size() )

func to_show(interface):
	if not(in_show.has(interface)):
		in_show.append(interface)
	interface.show()

func _on_CheckBox_toggled(button_pressed):
	
	OS.window_fullscreen=button_pressed
	


func _on_Exit_pressed():
	if in_show.size()==0:
		get_tree().quit()



