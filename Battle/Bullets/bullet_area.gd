extends Area2D
class_name BulletArea

var damage_mode

@onready var parent: bullet = get_parent()

@onready var damage = parent.damage
@onready var iframes = parent.iframe_grant
@onready var kr = parent.kr_amount
