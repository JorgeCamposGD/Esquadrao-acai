extends HTTPRequest

const API_KEY="AIzaSyBv7Qo7BgIFGuRNvH-BdldYmRc_9fe-K8Q"
const CREATE_ACOUNT_ADRESS="https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=%s"%API_KEY
const LOGIN_ADRESS="https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=%s"%API_KEY
const FIRESTORE="acai-squad-test"
var user_info
var ipv6
var user_ip
var getting_ip=false
var ip_adress="https://api6.ipify.org?format=json"
func _ready():
	
	
	ipv6=self.request(ip_adress,[],false,HTTPClient.METHOD_HEAD)
	getting_ip=true

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
	self.request(CREATE_ACOUNT_ADRESS, [], false, HTTPClient.METHOD_POST, to_json(body))#converte o dicionario para json
	var result := yield(self, "request_completed") as Array
	if result[1] == 200:
		user_info = _get_user_info(result)


func login(email: String, password: String) -> void:
	var body := {
		"email": email,
		"password": password,
		"returnSecureToken": true
	}
	self.request(LOGIN_ADRESS, [], false, HTTPClient.METHOD_POST, to_json(body))
	var result := yield(self, "request_completed") as Array
	if result[1] == 200:
		user_info = _get_user_info(result)


func save_document(path: String, fields: Dictionary) -> void:
	var document := { "fields": fields }
	var body := to_json(document)
	var url := FIRESTORE + path
	self.request(url, _get_request_headers(), false, HTTPClient.METHOD_POST, body)


func get_document(path: String) -> void:
	var url := FIRESTORE + path
	self.request(url, _get_request_headers(), false, HTTPClient.METHOD_GET)


func update_document(path: String, fields: Dictionary) -> void:
	var document := { "fields": fields }
	var body := to_json(document)
	var url := FIRESTORE+ path
	self.request(url, _get_request_headers(), false, HTTPClient.METHOD_PATCH, body)


func delete_document(path: String) -> void:
	var url := FIRESTORE + path
	self.request(url, _get_request_headers(), false, HTTPClient.METHOD_DELETE)



func _on_HTTPRequest_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	print(result,response_code,headers,body)
#	var response_body := JSON.parse(body.get_string_from_ascii())
#	if getting_ip:
#		user_ip=response_body
#		print(JSON.parse(body.get_string_from_ascii()).result.error)
#		getting_ip=false
#	if response_code != 200:
#		print(response_body.result.error.message.capitalize())
#	else:
#		print(response_body.result)
#		yield(get_tree().create_timer(2.0), "timeout")

