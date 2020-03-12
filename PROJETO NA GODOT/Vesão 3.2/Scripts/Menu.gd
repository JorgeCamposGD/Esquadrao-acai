extends Control

onready var online=get_node("Login")
onready var email_login=$Login/Panel2/Login/Email/Email_adress
onready var password_login=$Login/Panel2/Login/Password/Email_password
onready var create_account=$Login/Panel2/Submit/Email2/Create_email
onready var create_password=$Login/Panel2/Submit/Password2/Create_password
onready var confirm_password=$Login/Panel2/Submit/Password3/Create_password

var peer




func _on_Play_pressed():

	pass
func _on_Play_p2p_pressed():
	pass # Replace with function body.


func _on_Play_host_pressed():
	pass
	#get_node("PopupPanel").show()


func _on_Exit_pressed():
	get_tree().quit()


func _on_Return_pressed():
	get_node("Panel/PopupPanel").hide()


func _on_Play_online_pressed():
	online.show()


func _on_Login_email_pressed():
	if email_login.get_text()!=null and password_login.get_text()!=null:
		Firebase.login(email_login.get_text(),password_login.get_text())


func _on_Login_email2_pressed():
	if create_account.get_text()!="":
		print(create_account.get_text())
		if (create_password.get_text()!="" and confirm_password.get_text()!=""): 
			if create_password.get_text()==confirm_password.get_text():
				
				Firebase.register(create_account.get_text(),create_password.get_text())
			else:
				print("a confirmação é diferente")
				print(create_account.get_text())
				print(confirm_password.get_text())
		else:
			print("coloque uma senha")
	else:
		print("colocar o endereço de email")
