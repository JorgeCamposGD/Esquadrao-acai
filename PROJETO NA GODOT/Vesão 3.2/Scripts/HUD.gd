extends Control
onready var fps_label=get_node("CanvasLayer/FPS")
onready var mobile_interface=get_node("CanvasLayer/Mobile_hud")
onready var texture_size=get_node("CanvasLayer/Mobile_hud/TextureButton").get_size()
onready var analog=get_node("CanvasLayer/Mobile_hud/TextureButton/Analog")
onready var texture_center=texture_size/2
onready var texture_pos=get_node("CanvasLayer/Mobile_hud/TextureButton").get_position()
onready var hp_bar=get_node("ProgressBar")
var fps
var Sistema=OS.get_name()
var touch_input=Vector2()
func _ready():
	Engine.set_target_fps(60)
	pass
#	if Sistema=="Android" or "IPhone":
#		mobile_interface.hide()
func _process(delta):
	fps=Engine.get_frames_per_second()
	fps_label.set_text("FPS: "+str(fps) )



func _on_TextureButton_gui_input(event):
	if (event is InputEventScreenTouch) or (event is InputEventScreenDrag):
		var touch_pos=event.position-texture_center
		touch_pos=touch_pos.normalized()*clamp(touch_pos.length(),1,50)
		analog.set_global_position(texture_pos+touch_pos+texture_center )
		touch_input=touch_pos.normalized()

func _on_TextureButton_button_up():
	analog.set_global_position(texture_pos+texture_center )
	touch_input=Vector2()

func get_input_vec():
	return touch_input

func set_hp(hp_max,hp_actual):
	hp_bar.set_value(hp_actual)
	hp_bar.set_max(hp_max)

