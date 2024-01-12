extends AnimatedSprite2D

var attackwindow = 2.5
var speed_mult = 1.0
var time = 0.4
var transtype = Tween.TRANS_QUINT
@onready var movetype = Global.item_list[Global.equipment["weapon"]].bar_trans_type

var direction:float
var critzone = Vector2(308,332)
var tw:Tween

var bar_number = 0
var hityet = true
signal hit(pos,crit,speed)
signal miss

var can_crit = false
func _ready() -> void:
	if int(Global.item_list[Global.equipment["weapon"]].weapon_type) > 0: can_crit = true
	tw = create_tween().set_ease(Tween.EASE_OUT).set_trans(transtype).set_parallel()
	tw.tween_property(self,"modulate:a",1,time)
	tw.set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(self,"position:x",550.0*sign(direction),attackwindow).as_relative().set_trans(movetype)
	tw.tween_property(self,"hityet",false,attackwindow/5.0)
	tw.chain()
	tw.tween_property(self,"modulate:a",0,time)
	tw.chain()
	tw.tween_callback(emit_signal.bind("miss"))
	tw.tween_callback(queue_free)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") && !hityet:
		hityet = true
		animation = "glow"
		get_viewport().set_input_as_handled()
		tw.kill()
		emit_signal("hit",position.x,position.x > critzone.x and position.x < critzone.y,550.0/attackwindow)
		var t = create_tween().set_ease(Tween.EASE_OUT).set_trans(transtype).set_parallel()
		if can_crit:
			t.tween_property(self,"modulate:a",0,time).set_delay(time/3.0)
			t.tween_property(self,"scale",Vector2(1.25,1.25),time)
			if position.x > critzone.x and position.x < critzone.y:
				$critical.play()
				t.tween_property(self,"modulate:b",0,time/2)
			else:
				$hit.play()
				t.tween_property(self,"modulate:r",0,time/2)
				t.tween_property(self,"modulate:g",0.8,time/2)
		else:
			t.tween_property(self,"modulate:a",0,time/2).set_delay(1.5)
			play("glow")
			if bar_number != 1:
				$Slashes.play("slash")
				$Slashes.rotation = randi_range(-80,80)
				$Slashes.scale= Vector2.ONE * (bar_number/2.0 + 0.5)
				$Slashes.modulate.a = 0.8
				$Slashes.global_position.x = lerpf($Slashes.global_position.x,320,0.85)
				$slash.play()
		await t.finished
		queue_free()
