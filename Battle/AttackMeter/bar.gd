extends AnimatedSprite2D
class_name AttackBar

const MOVE_SPEED: float = 210
const TIME: float = 0.3
const TRANSTYPE = Tween.TRANS_CUBIC
var speed_mult: float
var movetype: int = Global.item_list[Global.equipment["weapon"]].bar_trans_type
var single: bool = Global.item_list[Global.equipment["weapon"]].weapon_bars == 1

var direction: int
const critzone = Vector2(310, 330)
var tw: Tween

var hityet := true
signal hit(pos: Vector2, crit: bool, speed: float)
signal miss

var can_crit: bool = Global.item_list[Global.equipment["weapon"]].critical_hits

func _ready() -> void:
	$Area2D/CollisionShape2D.position.x = 25 * direction
	#if can_crit: create_tween().tween_callback($AnimationPlayer.play.bind("glow")).set_delay(randf_range(0, 0.2))
	tw = create_tween().set_ease(Tween.EASE_OUT).set_trans(TRANSTYPE).set_parallel()
	tw.tween_interval(TIME)
	tw.set_ease(Tween.EASE_IN_OUT)
	var _dist = abs(position.x - 320) * 2
	tw.tween_property(self, "position:x", _dist * sign(direction), _dist / (MOVE_SPEED * speed_mult)).as_relative().set_trans(movetype)
	tw.tween_property(self, "hityet", false, 0.1)
	await tw.finished
	tw = create_tween().set_ease(Tween.EASE_OUT).set_trans(TRANSTYPE).set_parallel()
	tw.tween_property(self, "self_modulate:a", 0, TIME)
	tw.chain()
	tw.tween_callback(emit_signal.bind("miss"))
	tw.tween_callback(queue_free)

@onready var Overlay: ColorRect = $Overlay

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") && !hityet:
		tw.kill()
		position.x = round(position.x / 2.0) * 2
		hityet = true
		get_viewport().set_input_as_handled()
		hit.emit(position.x, position.x > critzone.x and position.x < critzone.y and can_crit, MOVE_SPEED * speed_mult)
		var t := create_tween().set_ease(Tween.EASE_OUT).set_trans(TRANSTYPE).set_parallel()
		if !single:
			t.tween_property(self, "scale", Vector2(1.2, 1.5), TIME)
			t.tween_property(Overlay, "color:a", 0, TIME)
			frame = 2
			Overlay.color.a = 1
			Overlay.modulate.a = 1
			$hit.play()
		else:
			$AnimationPlayer.play("glow")
			t.tween_property(self, "modulate:a", 0, TIME).set_delay(TIME)
		if can_crit:
			if position.x > critzone.x and position.x < critzone.y:
				$critical.play()
				t.tween_property(self, "modulate:b", 0, TIME / 2)
			elif position.x > 70 and position.x < 570:
				$hit.play()
				Overlay.color.a = 0.7
				t.tween_property(self, "modulate:r", 0, TIME / 2)
			else:
				$hit.play()
				t.tween_property(self, "modulate:g", 0, TIME / 2)
				t.tween_property(self, "modulate:b", 0, TIME / 2)
		await t.finished
		queue_free()


func _on_enter_meter(area: Area2D) -> void:
	if area.is_in_group("attack_meter"):
		var t := create_tween().set_trans(TRANSTYPE).set_ease(Tween.EASE_IN)
		t.tween_property(self, "self_modulate:a", 1, 50.0 / (MOVE_SPEED * speed_mult))


func _on_exit_box(area: Area2D) -> void:
	if area.is_in_group("attack_meter"):
		var t := create_tween().set_trans(TRANSTYPE).set_ease(Tween.EASE_OUT)
		t.tween_property(self, "self_modulate:a", 0, 50.0 / (MOVE_SPEED * speed_mult))
