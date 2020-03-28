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
var player_info={
	"name":"",
	"host":false,
	"id":null
}
var network=Network
var peer
var ip
var cena=preload("res://scenes/Maps/Mapa alpha.tscn")

func _ready():
	var request_ip=Network.get_ip()
	if request_ip==null:
		yield(get_tree().create_timer(0.3), "timeout")
		_ready()
		return
	else:
		ip=request_ip
		Ip_label.set_text(Ip_label.get_text()+ip)
		print(ip)
func _on_Play_pressed():

	get_tree().change_scene_to(cena)
	print("olá android")
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

	player_info["name"]=nick_name.get_text()

	if nick_name.get_text()=="":
		notify_conect.set_text("insert Nick name")
	else:

		
		Global.create_server(player_info)



func _on_Conect_to_host_pressed():

	var ip=inserted_ip.get_text()


	if nick_name.get_text()=="":
		notify_conect.set_text("insert Nick name")

	else:
		player_info["name"]=nick_name.get_text()

		if ip!="" and is_vallid_ip(ip):

			Global.conect_to_server(ip,player_info)
			player_info["name"]=nick_name.get_text()
		else:
			notify_conect.set_text("Insert a valid IP")





func _on_insert_ip_text_changed(new_text):
	pass
#	match new_text.length():
#		4,9,14,19,24,29:
#			inserted_ip.text+=":"

func is_vallid_ip(ip_string):
	return true


func _on_Button_pressed():
	online.hide()
