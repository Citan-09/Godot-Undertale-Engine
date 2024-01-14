extends Node2D
class_name AttackBase

@onready var NonMask = $/root/main/Attacks
@onready var Mask = $/root/main/Attacks/BoxClipper/Mask
@onready var Camera: CameraFx = $/root/main/Camera
@onready var Box: BattleBox = $/root/main/CoreElements/BattleBox
@onready var Soul: SoulBattle = $/root/main/Soul_Battle
@onready var MenuSoul = $/root/main/Soul_Battle

var enemy_attacker: Enemy
# Non-bullets
var platform = preload("res://Battle/Platform/platform.tscn")

# Bullets
var bullet1 = preload("res://Battle/Bullets/defaultbullet.tscn")
var bone = preload("res://Battle/Bullets/Bone/bone.tscn")
var bone_spike = preload("res://Battle/Bullets/BoneSpike/bone_spike.tscn")
var blaster = preload("res://Battle/Bullets/Blaster/blaster.tscn")
var bullet_circle = preload("res://Battle/Bullets/bullet_circle.tscn")

var attack_id: int = 0
signal remove_attack(id: int)
signal remove_bullets

func add_bullet(_bullet: Node, mask: bool = true):
	if "shakeCamera" in _bullet: _bullet.shakeCamera.connect(Camera.add_shake)
	remove_bullets.connect(_bullet.fade)
	if mask: Mask.add_child(_bullet,true)
	else:
		NonMask.add_child(_bullet, true)
		NonMask.move_child(_bullet, 0)


func start_attack():
	pass # Override with actual attack



func end_attack():
	remove_bullets.emit()
	remove_attack.emit(attack_id)
