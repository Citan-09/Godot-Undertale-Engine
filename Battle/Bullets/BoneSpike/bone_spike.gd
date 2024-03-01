class_name BoneSpike extends Bullet

@export var collision_margin: float = 4

@onready var Warning: ReferenceRect = $Warning
@onready var ModeHint: Panel = $Warning/Panel
@onready var SpriteRect = get_node(sprite_path)

func fire(size: Vector2, warn_time: float = 0.4, remain_time: float = 1, mode: int = MODE_WHITE) -> void:
	damage_mode = mode
	SpriteRect.size = size
	Warning.size = size
	Warning.get_child(0).modulate = colors[damage_mode]
	$Alert.play()
	var alert_tween := create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	var alert_tween2 := create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	alert_tween.tween_property(ModeHint, "self_modulate:a", 1, warn_time / 5.0)
	alert_tween2.tween_property(Warning, "modulate:a", 0, warn_time * 7 / 8.0)
	alert_tween.tween_property(ModeHint, "self_modulate:a", 0, 4 * warn_time / 5.0)

	await get_tree().create_timer(warn_time, false).timeout
	Collision.shape = RectangleShape2D.new()
	Warning.hide()
	SpriteRect.show()
	Collision.shape.size.x = size.x
	Collision.position.x = size.x / 2.0
	SpriteRect.size.y = 0
	spike(remain_time)

const spike_time = 0.3

func spike(remain_time: float) -> void:
	$Spike.play()
	var tw := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel()
	tw.tween_property(SpriteRect, "size:y", Warning.size.y, spike_time)
	tw.tween_property(Collision.shape, "size:y", Warning.size.y - collision_margin, spike_time)
	tw.tween_property(Collision, "position:y", (Warning.size.y - collision_margin) / 2.0, spike_time)
	tw.tween_interval(remain_time)
	tw.chain().tween_property(SpriteRect, "size:y", 0, spike_time)
	tw.tween_property(Collision.shape, "size:y", 0, spike_time)
	tw.tween_property(Collision, "position:y", 0, spike_time)
	tw.tween_property(self, "modulate:a", 0, spike_time / 2.0).set_delay(spike_time / 2.0)
	tw.chain().tween_callback(queue_free)
