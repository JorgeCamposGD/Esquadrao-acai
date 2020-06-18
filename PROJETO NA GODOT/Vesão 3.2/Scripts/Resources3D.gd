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
			"Sniper":preload("res://assets/sounds/Som de armas/Som de flecha pra sniper.wav")
			}
var player_scene=preload("res://scenes/Player.tscn")

var turret_bullet=preload("res://scenes/Personagem/especiais/Bullet turret.tscn")

var drop_texture={
						1:
						{
							0:preload("res://assets/Icons/CRAFT E CONSUMIVEL/Icone-Coxinha.png"),
							1:preload("res://assets/Icons/CRAFT/Icone-Cupuacu.png"),
							2:preload("res://assets/Icons/CRAFT/Icone-Tucupi.png"),
							3:preload("res://assets/Icons/CRAFT/IconePato.png")
						},
						3:
						{
							0:preload("res://assets/Icons/CONSUMIVEL/Icone-Tigela-Acai.png"),
							1:preload("res://assets/Icons/CRAFT/Icone-Poraque.png"),
							2:preload("res://assets/Icons/CRAFT/Icone-Maniva.png"),
							3:preload("res://assets/Icons/CRAFT/Icone-Mandioca.png")
						},
						2:
						{
							0:preload("res://assets/Icons/CRAFT/Icone-Madeira.png"),
							1:preload("res://assets/Icons/CRAFT/Icone-Corda.png"),
							2:preload("res://assets/Icons/CRAFT/Icone-Sucata.png"),
							3:preload("res://assets/Icons/CRAFT/Icone-Poraque.png")
						},
						4:
						{
							0:preload("res://assets/Icons/CRAFT/IconeCarangueijo.png"),
							1:preload("res://assets/Icons/CRAFT/Icone-Manga.png"),
							2:preload("res://assets/Icons/CRAFT/Icone-Pimenta.png"),
							3:preload("res://assets/Icons/CRAFT/Icone-Granola.png")
						},

					0:{
						0:preload("res://assets/Icons/CRAFT/Icone-Municao.png")
					}
				}

func get_t_bullet(classe):
	return turret_bullet

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

func get_item():
	return drop_texture
