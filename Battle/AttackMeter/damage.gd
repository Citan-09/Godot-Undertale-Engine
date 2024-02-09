extends Control

@onready var Text: RichTextLabel = $Hp
@onready var Bar: ProgressBar = $Bar

var time: float = 0.6
var hp: int = 20
var max_hp: int = 20
var damage: int = 5
var miss := false

signal finished
signal damagetarget

func _ready() -> void:
	modulate.a = 0
	Bar.max_value = max_hp
	Bar.value = hp
	await get_tree().process_frame
	Bar.size.x = min(100 + max_hp / 5.0, 560)
	Bar.position.x = -Bar.size.x / 2.0
	if miss:
		Text.text = "[center][color=gray]MISS"
		Bar.hide()
	elif damage > 0:
		$Hit.play()
		Text.text = "[center][color=red]" + str(damage)
		emit_signal("damagetarget", damage)
	else:
		$Hit.play()
		emit_signal("damagetarget", damage)
		Text.text = "[center][color=gray]0"
		Bar.hide()
	
	var tw_flash := create_tween().set_loops(3)
	tw_flash.pause()
	tw_flash.tween_interval(0.1)
	tw_flash.tween_callback(show)
	tw_flash.tween_interval(0.1)
	tw_flash.tween_callback(hide)
	
	var tw := create_tween().set_parallel().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(Text, "position:y", -10, time).as_relative()
	tw.tween_property(self, "modulate:a", 1, time / 10.0)
	tw.tween_property(Bar, "value", -damage, time).as_relative()
	tw.set_parallel().chain().tween_callback(tw_flash.play)
	tw.tween_property(Text, "position:y", Text.position.y, time).set_ease(Tween.EASE_IN)
	
	await tw_flash.finished
	emit_signal("finished")
