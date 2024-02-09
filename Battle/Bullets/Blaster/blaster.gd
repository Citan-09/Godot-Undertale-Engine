extends Bullet
class_name Blaster

@export var time: float = 0.7
@export var beam_margin: float = 6

@onready var Beam: Control = $Sprite/Beam
@onready var Rect: NinePatchRect = $Sprite/Beam/NinePatchRect
@onready var AnimPlayer: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	Collision.shape = RectangleShape2D.new()
	Collision.shape.size = Vector2.ZERO


func fire(target: Vector2, size: float = 1, delay: float = 0.5, duration: float = 0.5, mode: int = MODE_WHITE) -> void:
	$load.play()
	scale = Vector2(max(size, 1), max(size, 1.5))
	damage_mode = mode
	target_position = target
	var distance: Vector2 = target_position - global_position
	velocity_tween = create_tween().set_ease(TweenEase).set_trans(TweenTrans).set_parallel()
	velocity_tween.tween_property(self, "position", distance, time).as_relative()
	velocity_tween.tween_property(self, "rotation", TAU, time).as_relative()
	velocity_tween.chain().tween_interval(delay - 0.3)
	velocity_tween.chain().tween_callback(AnimPlayer.play.bind("prepare"))
	velocity_tween.tween_interval(0.15)
	velocity_tween.chain().tween_callback($fire.play)
	velocity_tween.tween_callback(_blast.bind(duration))
	#await velocity_tween.finished
	#await get_tree().create_timer(delay -0.3, false).timeout
	#AnimPlayer.play("prepare")
	#await AnimPlayer.animation_finished
	#$fire.play()
	#_blast(duration)

const grow_time = 0.15

func _blast(duration: float) -> void:
	Collision.shape.size = Beam.size - Vector2.RIGHT * beam_margin
	shakeCamera.emit(0.5)
	Collision.position.y += Beam.size.y / 2.0
	Beam.show()
	AnimPlayer.play("fire")
	
	var tween_beam := create_tween().set_trans(Tween.TRANS_SINE).set_loops()
	tween_beam.pause()
	tween_beam.tween_property(Rect, "scale:x", 0.8, grow_time / 2.0)
	tween_beam.tween_property(Rect, "scale:x", 1.0, grow_time / 2.0)
	
	var tw_remove := create_tween()
	tw_remove.tween_interval(duration + grow_time)
	tw_remove.set_parallel()
	#tw_remove.tween_callback(tween_beam.stop)
	#tw_remove.chain().tween_interval(0.1)
	tw_remove.chain()
	tw_remove.tween_property(Beam, "modulate:a", 0, grow_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw_remove.tween_property(Collision, "scale:x", 0, grow_time)
	tw_remove.tween_callback(Collision.queue_free).set_delay(grow_time / 2.0)
	tw_remove.tween_property(Beam, "scale:x", 0, grow_time)
	tw_remove.chain().tween_callback(queue_free).set_delay(1.8)
	
	
	var tw := create_tween().set_trans(Tween.TRANS_CUBIC).set_parallel()
	tw.tween_property(Beam, "scale:x", 1, grow_time)
	tw.tween_property(Beam, "modulate:a", 1, grow_time).set_trans(Tween.TRANS_SINE)
	
	
	var tw_move := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw_move.tween_property(self, "position", Vector2.UP.rotated(rotation) * 800, 1.0).as_relative()
	tw_move.tween_callback(tween_beam.play)
	
	



