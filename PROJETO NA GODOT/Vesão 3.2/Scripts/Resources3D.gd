extends Spatial

var environements={"mobile":preload("res://assets/maps/optimised.tres"), 
				"pc":preload("res://scenes/waterEnvi.tres")
			}
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
			"Pistol":preload("res://assets/sounds/Som de armas/pistola.wav"),
			"Shotgun":preload("res://assets/sounds/Som de armas/pistola.wav"),
			"Smg":preload("res://assets/sounds/Som de armas/metralhadora.wav"),
			"Sniper":preload("res://assets/sounds/Som de armas/metralhadora.wav")
			}
var player_scene=preload("res://scenes/Player.tscn")

func get_bullet(classe):
	return bullets[classe]
func get_sound(classe):
	return Sons[classe]
func get_special_resource(classe):
	return specials_resources[classe]

func get_envir(type):
	return environements[type]
func get_player():
	return player_scene
