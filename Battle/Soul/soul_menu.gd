@icon("res://Battle/Soul/soul.png")
extends CharacterBody2D
class_name SoulMenu

var time = 0.07
var enabled = true

var movetween: Tween

func enable() -> void:
	enabled = true
	if !is_node_ready(): await ready
	position = Vector2(320, 454)
	modulate.a = 0
	var tw = create_tween()
	tw.tween_property(self, "modulate:a", 1, 0.4)

func _enter_tree() -> void:
	enable()

func disable() -> void:
	if enabled:
		enabled = false
		var tw = create_tween()
		tw.tween_property(self, "modulate:a", 0, time)
		await tw.finished
		get_parent().remove_child.call_deferred(self)

func _on_movesoul(newpos: Vector2) -> void:
	if movetween and movetween.is_valid():
		movetween.kill()
	if is_inside_tree():
		movetween = get_tree().create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT).set_parallel()
	if movetween and movetween.is_valid():
		movetween.tween_property(self, "scale", Vector2.ZERO, 0.01)
		movetween.chain().tween_callback(set_position.bind(newpos))
		movetween.tween_property(self, "scale", Vector2.ONE, time * 2)



