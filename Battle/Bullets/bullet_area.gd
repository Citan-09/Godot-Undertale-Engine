extends Area2D

var damage_mode
var damage = 0.0
var kr = 0
var iframes = 0.0

@onready var EnemyStats = get_parent().stats
func _ready() -> void:
	damage = EnemyStats.get("damage",0)
	kr = EnemyStats.get("kr_amount",0)
	iframes = EnemyStats.get("iframes_grant",50)
