extends Node
class_name AttackBase

@onready var Main: BattleMain = Global.scene_container.current_scene
@onready var NonMask: Node = Main.AttacksParent
@onready var Mask: AttackManager = Main.Attacks
@onready var Camera: CameraRemoteController = Main.Camera
@onready var Box: BattleBox = Main.Box
@onready var BoxRectClip: Control = Box.RectClip
@onready var BoxRectNoClip: Control = Box.RectNoClip
@onready var Soul: SoulBattle = Main.Soul_Battle

#var enemy_attacker: Node
# Non-bullets
var platform: PackedScene = preload("res://Battle/Platform/platform.tscn")

# Bullets
var bullet1: PackedScene = preload("res://Battle/Bullets/defaultbullet.tscn")
var bone: PackedScene = preload("res://Battle/Bullets/Bone/bone.tscn")
var bone_spike: PackedScene = preload("res://Battle/Bullets/BoneSpike/bone_spike.tscn")
var blaster: PackedScene = preload("res://Battle/Bullets/Blaster/blaster.tscn")
var bullet_circle: PackedScene = preload("res://Battle/Bullets/bullet_circle.tscn")

var attack_id: int = 0
signal remove_attack(id: int)
signal remove_bullets


enum Masking {
	ABSOLUTE_CLIP,
	ABSOLUTE,
	RELATIVE_BOX_CLIP,
	RELATIVE_BOX,
}


## BULLETS ADDED TO BOX MIGHT MOVE UNEXPECTEDLY DUE TO BOX RESIZING!
func add_bullet(_bullet: Node, mask: int = 0) -> void:
	if "shakeCamera" in _bullet: _bullet.shakeCamera.connect(Camera.add_shake)
	remove_bullets.connect(_bullet.fade)
	match mask:
		Masking.ABSOLUTE:
			NonMask.add_child(_bullet, true)
			NonMask.move_child(_bullet, 0)
		Masking.ABSOLUTE_CLIP:
			Mask.add_child(_bullet, true)
		Masking.RELATIVE_BOX:
			BoxRectNoClip.add_child(_bullet, true)
		Masking.RELATIVE_BOX_CLIP:
			BoxRectClip.add_child(_bullet, true)

## BULLETS ADDED TO BOX MIGHT MOVE UNEXPECTEDLY DUE TO BOX RESIZING!
func quick_bullet(_bullet: PackedScene, pos: Vector2, rot: float = 0, mask: Masking = Masking.ABSOLUTE_CLIP) -> Node:
	var b: Node = _bullet.instantiate()
	add_bullet(b, mask)
	b.position = pos
	b.rotation_degrees = rot
	return b

## Use this to start your attacks
func start_attack() -> void:
	pass  # Override with actual attack


func end_attack() -> void:
	remove_bullets.emit()
	remove_attack.emit(attack_id)
