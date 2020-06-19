extends Control


onready var fps_label=get_node("CanvasLayer/FPS")
onready var mobile_interface=get_node("CanvasLayer/Mobile_hud")
onready var texture_size=get_node("CanvasLayer/Mobile_hud/TextureButton").get_size()
onready var analog=get_node("CanvasLayer/Mobile_hud/TextureButton/Analog")
onready var texture_center=texture_size/2
onready var texture_pos=get_node("CanvasLayer/Mobile_hud/TextureButton").get_position()
onready var hp_bar=get_node("ProgressBar")
onready var name_label=get_node("NameLabel")
onready var txt_btn=get_node("CanvasLayer/Mobile_hud/TextureButton")
onready var ammo_display=$CanvasLayer/Pc_hud/Weapons/Ammo
onready var res_hud=[get_node("CanvasLayer/Pc_hud/Constructions/Resources/Res0"),get_node("CanvasLayer/Pc_hud/Constructions/Resources/Res1"),get_node("CanvasLayer/Pc_hud/Constructions/Resources/Res2"),get_node("CanvasLayer/Pc_hud/Constructions/Resources/Res3")]
onready var mission=get_node("CanvasLayer/Mission")
onready var fim=get_node("CanvasLayer/Panel")
var fps
var Sistema=OS.get_name()
var touch_input=Vector2()
var my_name=""
var analog_index=null
var events={}
var ammo
var resources
var started=false
func start():
	set_physics_process(true)
	get_node("Pause Panel").hide()
	mission.set_text(tr("Missao")+str(Global.get_tempo()) )

func _ready():
	set_physics_process(false)
	_set_size(Settings.resolution)

	set_resources(get_parent().get_resources())
	var classe_name
	match Global.get_my_info()["classe"]:
		1:
			classe_name="Pistol"
		2:
			classe_name="Shotgun"
		3:
			classe_name="Smg"
		4:
			classe_name="Sniper"

	get_node("CanvasLayer/Pc_hud/Weapons/"+classe_name).show()
	get_node("CanvasLayer/Pc_hud/Constructions/"+classe_name).show()
	get_node("Pause Panel").show()
	get_node("Pause Panel/Wait_players").set_text(tr("ESPERANDO"))
	Engine.set_target_fps(60)
	if Sistema=="Android":
		mobile_interface.show()
	name_label.set_text(my_name)
func all_dead():
	get_node("CanvasLayer/Panel2").show()
	
func disconect():
	get_node("CanvasLayer/Panel3").show()
func _physics_process(delta):
	mission.set_text(tr("Missao")+str(int( Global.get_tempo() )   ) )

func set_finish():
	fim.show()
func _process(delta):
	if Global.get_my_info()["ammo"]!=ammo:
	
		ammo=Global.get_my_info()["ammo"]

		ammo_display.set_text(tr("AMMO_ACOUNT")+":"+str(ammo) )
		
	fps=Engine.get_frames_per_second()
	fps_label.set_text("FPS: "+str(fps) )
	if Sistema=="Android":
		
		if not(txt_btn.is_pressed()):
			if Global.is_master(get_parent()):
				analog.set_global_position(texture_pos+texture_center )
				touch_input=Vector2()

func set_name(new_name):
	my_name=new_name
	_ready()
func set_ammo(qtd):
	ammo_display.set_text(tr("AMMO_ACOUNT"+":"+str(qtd)))

func set_resources(res):

	for x in range(res.size()):
		res_hud[x].set_text(str(res[x]))

func _on_TextureButton_gui_input(event):

	var btn_pos=txt_btn.get_global_position()
	if Global.is_master(get_parent()):
		if (event is InputEventScreenTouch) or (event is InputEventScreenDrag): 
			
			events[event.index]=event
			var btn_event
		
			if events.size()>1:
				for key in events:
					var last_pos
					var new_pos
					if btn_event==null:
						btn_event=events[key]
					else:
						last_pos=btn_event.position
						new_pos=events[key].position
						
						if new_pos.distance_to(btn_pos)<last_pos.distance_to(btn_pos):
							btn_event=events[key]
			else:
				btn_event=event
			button_event(btn_event)
			events.clear()



func button_event(event):

		var touch_pos=event.position-texture_center
		touch_pos=touch_pos.normalized()*clamp(touch_pos.length(),1,50)
		analog.set_global_position(texture_pos+touch_pos+texture_center )
		touch_input=touch_pos.normalized()

 
	

func get_input_vec():
	return touch_input

func set_hp(hp_max,hp_actual):
	hp_bar.set_value(hp_actual)
	hp_bar.set_max(hp_max)






func _on_Button_pressed():
	get_tree().quit()


func _on_Voltar_ao_menu_pressed():
	get_tree().quit()
