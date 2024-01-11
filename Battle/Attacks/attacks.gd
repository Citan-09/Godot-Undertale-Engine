extends Node2D
class_name AttackBase

@onready var NonMask = $/root/main/Attacks
@onready var Mask = $/root/main/Attacks/BoxClipper/Mask
@onready var Camera = $/root/main/Camera
@onready var Box :BattleBox= $/root/main/CoreElements/BattleBox
@onready var Soul :SoulBattle= $/root/main/Soul_Battle
@onready var MenuSoul = $/root/main/Soul_Battle

var enemy_attacker : Enemy
var bullet1 = preload("res://Battle/Bullets/defaultbullet.tscn")
var bullet_circle = preload("res://Battle/Bullets/bullet_circle.tscn")
signal remove_bullets

func add_bullet(_bullet:Node,mask:bool = true):
	remove_bullets.connect(_bullet.fade)
	if mask: Mask.add_child(_bullet)
	else:
		NonMask.add_child(_bullet,true)
		NonMask.move_child(_bullet,0)

func end_attack():
	emit_signal("remove_bullets")
