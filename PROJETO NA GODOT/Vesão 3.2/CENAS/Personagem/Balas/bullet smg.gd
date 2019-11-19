extends "res://CENAS/Personagem/Balas/bullet.gd"
export (float,0,100,0.5) var speed
export (float,0,100,0.5) var dmg

func _ready():
	set_bullet_speed_and_damage(speed,dmg)
