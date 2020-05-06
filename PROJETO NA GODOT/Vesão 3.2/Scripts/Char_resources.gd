extends Spatial

var bullets={
			"Pistol":preload("res://scenes/Personagem/Balas/bullet pistol.tscn"),
			"Shotgun":preload("res://scenes/Personagem/Balas/bullet shotgun.tscn"),
			"Smg":preload("res://scenes/Personagem/Balas/bullet smg.tscn"),
			"Sniper":preload("res://scenes/Personagem/Balas/bullet sniper.tscn")
			}
var specials_resources={
			"Pistol":preload("res://scenes/Personagem/especiais/Grenade.tscn"),
			"Shotgun":preload("res://scenes/Personagem/especiais/Wall.tscn"),
			"Smg":preload("res://scenes/Personagem/especiais/Turret.tscn"),
			"Sniper":preload("res://scenes/Personagem/especiais/Trap.tscn")
			}
var Sons={
			"Pistol":preload("res://assets/sounds/Pistola.wav"),
			"Shotgun":preload("res://assets/sounds/Shotgun.wav"),
			"Smg":preload("res://assets/sounds/Smg.wav"),
			"Sniper":preload("res://assets/sounds/Sniper.wav")
			}
var player_scene=preload("res://scenes/Player.tscn")

func ocult():
	.hide()
	get_node("PLAYER/Cam").queue_free()
func get_bullet(classe):
	return bullets[classe]
func get_sound(classe):
	return Sons[classe]
func get_special_resource(classe):
	return specials_resources[classe]

func get_player():
	return player_scene
