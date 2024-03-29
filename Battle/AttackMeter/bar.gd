extends AnimatedSprite2D
class_name AttackBar

const MOVE_SPEED: float = 210
const TIME: float = 0.25
const TRANSTYPE := Tween.TRANS_CUBIC
var speed_mult: float
const movetype := Tween.TRANS_LINEAR
var single_bar: bool = Global.item_list[Global.equipment["weapon"]].weapon_bars == 1

var direction: int
const critzone = Vector2(310, 330)
var tw: Tween

var hityet := false
signal hit(pos: Vector2, crit: bool, speed: float)
signal miss

signal about_to_fade_out

var can_crit: bool = Global.item_list[Global.equipment["weapon"]].critical_hits

func _ready() -> void:
	tw = create_tween().set_ease(Tween.EASE_OUT).set_trans(TRANSTYPE).set_parallel()
	tw.tween_interval(TIME)
	tw.set_ease(Tween.EASE_IN_OUT)
	var _dist = abs(position.x - 320) * 2
	tw.tween_property(self, "position:x", _dist * sign(direction), _dist / (MOVE_SPEED * speed_mult)).as_relative().set_trans(movetype)
	await tw.finished
	tw = create_tween().set_ease(Tween.EASE_OUT).set_trans(TRANSTYPE).set_parallel()
	tw.tween_callback(hide)
	tw.tween_callback(emit_signal.bind("miss"))
	tw.tween_callback(queue_free)

@onready var Overlay: ColorRect = $Overlay

func _unhandled_input(event: InputEvent) -> void:
	if !event.is_action_pressed("ui_accept") or hityet:
		return
	tw.kill()
	position.x = round(position.x / 2.0) * 2
	hityet = true
	get_viewport().set_input_as_handled()
	hit.emit(position.x, position.x > critzone.x and position.x < critzone.y and can_crit, MOVE_SPEED * speed_mult)
	var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(TRANSTYPE).set_parallel()
	if !single_bar:
		tween.tween_property(self, "scale", Vector2(1.2, 1.5), TIME)
		tween.tween_property(Overlay, "color:a", 0, TIME)
		frame = 2
		Overlay.color.a = 1
		Overlay.modulate.a = 1
		$hit.play()
	else:
		$AnimationPlayer.play("glow")
		tween.tween_interval(1.4)
	if can_crit:
		if position.x > critzone.x and position.x < critzone.y: #Critical hit
			$critical.play()
			tween.tween_property(self, "modulate:b", 0, TIME / 2)
		elif position.x > 70 and position.x < 570: # Normal hit
			$hit.play()
			Overlay.color.a = 0.7
			tween.tween_property(self, "modulate:r", 0, TIME / 2)
		else: # Red (basically miss)
			$hit.play()
			tween.tween_property(self, "modulate:g", 0, TIME / 2)
			tween.tween_property(self, "modulate:b", 0, TIME / 2)
	await tween.finished
	tween = create_tween().set_trans(TRANSTYPE)
	tween.tween_property(self, "modulate:a", 0 , TIME).set_delay(TIME)
	tween.tween_callback(queue_free)
	about_to_fade_out.emit()

