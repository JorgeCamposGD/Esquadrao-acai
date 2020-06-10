extends Spatial

onready var sprite=get_node("Sprite")
var classe_item
var type
func set_text(text,classe_item,type):
	sprite.set_texture(text)
	self.classe_item=classe_item
	self.type=type

func _on_Area_body_entered(body):
	if body.has_method("colect"):
		body.colect(self,classe_item,type)

remotesync func colected():
	queue_free()



