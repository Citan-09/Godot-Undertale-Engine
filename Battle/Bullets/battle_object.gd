extends Node2D
class_name BattleObject

@export var TweenTrans := Tween.TRANS_QUAD
@export var TweenEase := Tween.EASE_IN_OUT

var velocity := Vector2.ZERO
var velocity_tween: Tween

enum fire_modes {
	VELOCITY,
	TWEEN
}

func fade():
	var fadetw = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	fadetw.tween_property(self, "modulate:a", 0, 0.5)
	fadetw.tween_callback(queue_free)
