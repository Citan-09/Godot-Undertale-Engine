extends Node2D
@export var velt = Vector2(0,-50)
var vel = velt

@onready var back = $Bg
@onready var mid = $Mg
# Called when the node enters the scene tree for the first time.

func nothing():
	pass
func tweenvelclock():
	var t =get_tree().create_tween().set_loops()
	t.tween_property(self,"vel",-velt,2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN)
	t.tween_property(self,"vel",velt,0.4).set_trans(Tween.TRANS_CUBIC)
	t.tween_callback(nothing)
