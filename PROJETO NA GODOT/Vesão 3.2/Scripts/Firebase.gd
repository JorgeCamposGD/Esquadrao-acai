extends Node
#Okay
signal ip_recived

const API_KEY="AIzaSyBv7Qo7BgIFGuRNvH-BdldYmRc_9fe-K8Q"
const CREATE_ACOUNT_ADRESS="https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=%s"%API_KEY
const LOGIN_ADRESS="https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=%s"%API_KEY
const FIRESTORE="acai-squad-test"

onready var firebase_request=$Firebase
onready var ipv6_request=$IPV6

var user_info
var ipv6
var user_ip
var getting_ip=false
var ip_adress="https://api.ipify.org"



func _get_user_info(result: Array) -> Dictionary:
	var result_body := JSON.parse(result[3].get_string_from_ascii()).result as Dictionary
	return {
		"token": result_body.idToken,
		"id": result_body.localId
	}


func _get_request_headers() -> PoolStringArray:
	return PoolStringArray([
		"Content-Type: application/json",
		"Authorization: Bearer %s" % user_info.token
	])


func register(email: String, password: String) -> void:
	var body := {
		"email": email,
		"password": password,
	}
	#cria um dicionario com o email e senha
	firebase_request.request(CREATE_ACOUNT_ADRESS, [], false, HTTPClient.METHOD_POST, to_json(body))#converte o dicionario para json
	var result := yield(firebase_request, "request_completed") as Array
	if result[1] == 200:
		user_info = _get_user_info(result)


func login(email: String, password: String) -> void:
	var body := {
		"email": email,
		"password": password,
		"returnSecureToken": true
	}
	firebase_request.request(LOGIN_ADRESS, [], false, HTTPClient.METHOD_POST, to_json(body))
	var result := yield(firebase_request, "request_completed") as Array
	if result[1] == 200:
		user_info = _get_user_info(result)


func save_document(path: String, fields: Dictionary) -> void:
	var document := { "fields": fields }
	var body := to_json(document)
	var url := FIRESTORE + path
	firebase_request.request(url, _get_request_headers(), false, HTTPClient.METHOD_POST, body)


func get_document(path: String) -> void:
	var url := FIRESTORE + path
	firebase_request.request(url, _get_request_headers(), false, HTTPClient.METHOD_GET)


func update_document(path: String, fields: Dictionary) -> void:
	var document := { "fields": fields }
	var body := to_json(document)
	var url := FIRESTORE+ path
	firebase_request.request(url, _get_request_headers(), false, HTTPClient.METHOD_PATCH, body)


func delete_document(path: String) -> void:
	var url := FIRESTORE + path
	firebase_request.request(url, _get_request_headers(), false, HTTPClient.METHOD_DELETE)



func _on_HTTPRequest_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	print(result,response_code,headers,body)




func _on_IPV6_request_completed(result, response_code, headers, body):
	ipv6=body.get_string_from_ascii()
	emit_signal("ip_recived",ipv6)

func get_ip() -> void:
	var self_ip

	if ipv6!=null:
		self_ip=ipv6
	else:
		if ipv6_request.get_http_client_status ( )==HTTPClient.STATUS_DISCONNECTED:
			ipv6_request.request(ip_adress,[],false,HTTPClient.METHOD_GET)
		
		if ipv6!=null:
			self_ip=ipv6
			



func _on_Firebase_request_completed(result, response_code, headers, body):
	var response_body := JSON.parse(body.get_string_from_ascii())
	if getting_ip:
		user_ip=response_body
		print(JSON.parse(body.get_string_from_ascii()).result.error)
		getting_ip=false
	if response_code != 200:
		print(response_body.result.error.message.capitalize())
	else:
		print(response_body.result)
		yield(get_tree().create_timer(2.0), "timeout")
