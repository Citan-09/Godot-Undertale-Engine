extends CanvasLayer

var time = 0.5
var transtype = Tween.TRANS_EXPO

var targetdef = 0
@onready var meter = $Meter
@onready var bar = preload("res://Battle/AttackMeter/bar.tscn")
var hits: float
var speed_mult = 1.0
var targetid = 0

var target: int
signal calculated
signal damagetarget(damage, target, crit)
signal missed(target)
var distance = 0
var score = 0
var misses = 0
var crits = 0

var summonclock: Tween
func _ready() -> void:
	meter.modulate.a = 0
	meter.scale.x = 0.33
	var tw = create_tween().set_ease(Tween.EASE_OUT).set_trans(transtype).set_parallel()
	tw.tween_property(meter, "scale:x", 1, time)
	tw.tween_property(meter, "modulate:a", 1, time / 2.0)  #.set_trans(Tween.TRANS_LINEAR)
	var randir = (randi_range(0, 1) * 2)-1
	var summonpos = Vector2(43, 320)
	if randir == 1:
		summonpos.x = 43
	elif randir == -1:
		summonpos.x = 597
	hits = Global.item_list[Global.equipment["weapon"]].weapon_bars
	speed_mult = Global.item_list[Global.equipment["weapon"]].weapon_speed
	summonclock = create_tween().set_loops(hits)
	summonclock.tween_callback(summonbar.bind(summonpos, randir))
	summonclock.tween_interval(0.2 + randi_range(0, 1) * 0.1)
	for i in hits:
		await calculated
	var damage = finalcalculation()
	if misses < hits:
		emit_signal("damagetarget", damage, target, crits == hits)
	else:
		emit_signal("missed", target)

func remove_meter():
	var tw = create_tween().set_ease(Tween.EASE_OUT).set_trans(transtype).set_parallel()
	tw.tween_property(meter, "scale:x", 0, time)
	tw.tween_property(meter, "modulate:a", 0, time / 2.0)  #.set_trans(Tween.TRANS_LINEAR)
	tw.chain().tween_callback(queue_free).set_delay(0.2)

func summonbar(position, direction):
	var clonebar = bar.instantiate()
	clonebar.bar_number = (hits - summonclock.get_loops_left() + 1) / hits
	clonebar.hit.connect(calculate)
	clonebar.miss.connect(miss)
	clonebar.speed_mult = speed_mult
	clonebar.position = position
	clonebar.direction = direction
	add_child(clonebar)
	move_child(clonebar, 1)

func miss():
	misses += 1
	emit_signal("calculated")

func calculate(posx: int, crit: bool, hspeed: float):
	crits += int(crit)
	distance = abs(posx - $Meter.position.x)
	if distance <= 12:
		distance = 12
	distance /= 275.0
	if hits <= 1:
		distance = 2 * (1- distance)
	else:
		distance = distance * hspeed / 10.0 - 0.8
		if (22 <= distance and distance < 28): score += 10
		if (16 <= distance and distance < 22): score += 15
		if (10 <= distance and distance < 16): score += 20
		if (5 <= distance and distance < 10): score += 40
		if (4 <= distance and distance < 5): score += 50
		if (3 <= distance and distance < 4): score += 70
		if (2 <= distance and distance < 3): score += 80
		if (1 <= distance and distance < 2): score += 90
		if (distance < 1): score += 110
	emit_signal("calculated")

func finalcalculation():
	var damage = Global.player_attack + 10 + Global.item_list[Global.equipment["weapon"]].attack_amount + Global.item_list[Global.equipment["armor"]].attack_amount + Global.temp_atk
	damage -= targetdef
	if hits <= 1:
		return round((damage + randf_range(-2, 2)) * distance)
	else:
		if score > 430: score *= 1.4
		if score > 390: score *= 1.2
		return round(damage * (score / 160.0) * (4.0 / hits)) + round(randf_range(-2, 2))

