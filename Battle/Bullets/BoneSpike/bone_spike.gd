extends bullet

@export var collision_margin: float = 4

@onready var Warning = $Warning


func fire(size: Vector2, warn_time: float = 0.4, remain_time: float = 1, mode: damage_modes = damage_modes.WHITE):
	damage_mode = mode
	Sprite.size = size
	Warning.size = size
	Warning.get_child(0).modulate = colors[damage_mode]
	$Alert.play()
	var alert_tween = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	var alert_tween2 = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	alert_tween.tween_property(Warning.get_child(0),"self_modulate:a",1,warn_time/5.0)
	alert_tween2.tween_property(Warning,"modulate:a",0,warn_time * 7/8.0)
	alert_tween.tween_property(Warning.get_child(0),"self_modulate:a",0,4 * warn_time/5.0)
	
	await get_tree().create_timer(warn_time, false).timeout
	Collision.shape = RectangleShape2D.new()
	Warning.hide()
	Sprite.show()
	Collision.shape.size.x = size.x
	Collision.position.x = size.x/2.0
	Sprite.size.y = 0
	spike(remain_time)

const spike_time = 0.3

func spike(remain_time):
	$Spike.play()
	var tw = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART).set_parallel()
	tw.tween_property(Sprite,"size:y",Warning.size.y,spike_time)
	tw.tween_property(Collision.shape,"size:y",Warning.size.y - collision_margin,spike_time)
	tw.tween_property(Collision,"position:y",(Warning.size.y - collision_margin)/2.0,spike_time)
	tw.tween_interval(remain_time)
	tw.chain().tween_property(Sprite,"size:y",0,spike_time)
	tw.tween_property(Collision.shape,"size:y",0,spike_time)
	tw.tween_property(Collision,"position:y",0,spike_time)
	tw.tween_property(self,"modulate:a",0,spike_time/2.0).set_delay(spike_time/2.0)
	tw.chain().tween_callback(queue_free)
