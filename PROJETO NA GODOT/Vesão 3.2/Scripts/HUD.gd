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
var fps
var Sistema=OS.get_name()
var touch_input=Vector2()
var my_name=""
var analog_index=null
var events={}
func _ready():

	Engine.set_target_fps(60)
	if Sistema=="Android":
		mobile_interface.show()
	name_label.set_text(my_name)
func _process(delta):
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




