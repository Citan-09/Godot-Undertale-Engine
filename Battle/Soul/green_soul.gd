extends Node2D
class_name GreenShielding

const DEF_COL := Color("0028ff")
const HIT_COL := Color("ff0000")
const RAD: int = 28
const COLOR := Color.DARK_GREEN
const TIME = 0.2

var always_remove_shielded_bullets := true

func _draw() -> void:
	draw_arc(Vector2.ZERO, RAD, 0, TAU, 128, COLOR, 1)

@onready var HitTimer: Timer = $Timer
@onready var Line: Line2D = $Shield/Col/Line2D
@onready var Shield: Area2D = $Shield

var shieldtween: Tween

func _ready() -> void:
	Line.modulate = DEF_COL


func _on_timer_timeout() -> void:
	Line.modulate = DEF_COL


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left"):
		_change_shield_rot_deg(0)
	if event.is_action_pressed("ui_right"):
		_change_shield_rot_deg(180)
	if event.is_action_pressed("ui_up"):
		_change_shield_rot_deg(90)
	if event.is_action_pressed("ui_down"):
		_change_shield_rot_deg(270)
	

func _change_shield_rot_deg(to: int):
	shieldtween = create_tween().set_trans(Tween.TRANS_SINE)
	shieldtween.tween_property(Shield, "rotation_degrees", to, TIME)


func _on_shield_area_entered(area: Area2D) -> void:
	if area is BulletArea:
		assert(area.parent.has_method("_on_hit_player_shield"), "Bullet is missing \"_on_hit_player_shield\" method.")
		if always_remove_shielded_bullets: area.parent._on_hit_player_shield.call_deferred()
		$ding.play()
		Line.modulate = HIT_COL
		HitTimer.start()
