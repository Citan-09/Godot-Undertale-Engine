extends Node
class_name AttackMeter

const TIME: float = 0.5
const transtype := Tween.TRANS_QUAD

var targetdef: int = 0
@onready var meter: Sprite2D = $Meter
@onready var bar: PackedScene = preload("res://Battle/AttackMeter/bar.tscn")
var total_bars: int
var speed_mult: float = 1.0
var targetid: int = 0

var target: int
signal calculated
signal damagetarget(damage: int, target: int, crit: bool)
signal missed(target: int)
var distance: float = 0
var score: int = 0
var misses: int = 0
var crits: int = 0
var hits: int = 0

var can_crit: bool = Global.item_list[Global.equipment["weapon"]].critical_hits

func _ready() -> void:
	meter.modulate.a = 0
	meter.scale.x = 0.33
	var tw := create_tween().set_trans(transtype).set_parallel().set_ease(Tween.EASE_OUT)
	tw.tween_interval(0.1)
	tw.chain()
	tw.tween_property(meter, "modulate:a", 1, TIME / 2)
	tw.tween_property(meter, "scale:x", 1, TIME)
	var randir: int = (randi_range(0, 1) * 2)-1
	var summonpos := Vector2(320, 320)
	if randir == 1:
		summonpos.x = 40
	elif randir == -1:
		summonpos.x = 600
	total_bars = Global.item_list[Global.equipment["weapon"]].weapon_bars
	speed_mult = Global.item_list[Global.equipment["weapon"]].weapon_speed
	for i in total_bars:
		summonbar(summonpos , randir, (randi_range(0, 2) * 0.05 + 0.25 * i) / Global.item_list[Global.equipment["weapon"]].weapon_speed)
	for i in total_bars:
		await calculated
	var damage := finalcalculation()
	if misses < total_bars:
		damagetarget.emit(damage, target, crits == total_bars)
	else:
		missed.emit(target)
	

func remove_meter() -> void:
	var tw := create_tween().set_trans(transtype).set_parallel().set_ease(Tween.EASE_IN)
	tw.tween_property(meter, "scale:x", 0b, TIME)
	tw.tween_property(meter, "modulate:a", 0, TIME)
	tw.chain().tween_callback(queue_free).set_delay(0.2)
	


func summonbar(position: Vector2, direction: int, delay: float) -> void:
	await get_tree().create_timer(delay, false).timeout
	var clonebar: AttackBar = bar.instantiate() as AttackBar
	clonebar.hit.connect(calculate)
	clonebar.miss.connect(miss)
	clonebar.speed_mult = speed_mult
	clonebar.position = position
	clonebar.direction = direction
	add_child(clonebar)
	move_child(clonebar, 1)
	clonebar.about_to_fade_out.connect(func():
		hits += 1
		print(hits)
		if (self.hits + self.misses) >= self.total_bars: self.remove_meter()
		)

func miss() -> void:
	misses += 1
	calculated.emit()


func calculate(posx: int, crit: bool, hspeed: float) -> void:
	crits += int(crit)
	distance = abs(posx - $Meter.position.x)
	if distance <= 12:
		distance = 12
	distance /= 275.0
	if total_bars <= 1:
		distance = 2 * (1- distance)
	else:
		distance = distance * hspeed / 7.0 - 0.8
		if (28 <= distance): score += 1
		if (22 <= distance and distance < 28): score += 10
		if (16 <= distance and distance < 22): score += 15
		if (10 <= distance and distance < 16): score += 20
		if (5 <= distance and distance < 10): score += 40
		if (4 <= distance and distance < 5): score += 50
		if (3 <= distance and distance < 4): score += 70
		if (2 <= distance and distance < 3): score += 80
		if (1 <= distance and distance < 2): score += 90
		if (distance < 1): score += 110
	calculated.emit()

func finalcalculation() -> int:
	var damage: int = Global.player_attack + 10 + Global.item_list[Global.equipment["weapon"]].attack_amount + Global.item_list[Global.equipment["armor"]].attack_amount + Global.temp_atk
	damage -= targetdef
	if total_bars <= 1:
		return round((damage + randf_range(-2, 2)) * distance)
	if can_crit:
		if score > 440: score *= 1.4
		if score > 380: score *= 1.2
	return round(damage * (score / 160.0) * (4.0 / total_bars)) + round(randf_range(-2, 2))


