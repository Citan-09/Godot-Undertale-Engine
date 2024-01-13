extends bullet

@export var time = 0.7
@export var beam_margin: float = 6

@onready var Beam = $Beam
@onready var Beams = [$Beam/Main,$Beam/Small,$Beam/Smaller]
@onready var AnimPlayer = $AnimationPlayer

func _ready():
	Collision.shape = RectangleShape2D.new()
	Collision.shape.size = Vector2.ZERO


func fire(target: Vector2, size: float = 1, delay: float = 0.5, duration: float = 0.5, mode: damage_modes = damage_modes.WHITE):
	$load.play()
	scale = Vector2(max(size, 1), max(size, 1.5))
	damage_mode = mode
	target_position = target
	var distance: Vector2 = target_position - global_position
	velocity_tween = create_tween().set_ease(TweenEase).set_trans(TweenTrans).set_parallel()
	velocity_tween.tween_property(self, "position", distance, time).as_relative()
	velocity_tween.tween_property(self, "rotation", TAU, time).as_relative()
	await velocity_tween.finished
	await get_tree().create_timer(delay-0.3,false).timeout
	AnimPlayer.play("prepare")
	await AnimPlayer.animation_finished
	$fire.play()
	_blast(duration)

const grow_time = 0.2
const shrink_time = 0.5

func _blast(duration):
	Collision.shape.size = Beam.size - Vector2.RIGHT * beam_margin
	shakeCamera.emit(0.5)
	Collision.position.y += Beam.size.y/2.0
	Beam.show()
	AnimPlayer.play("fire")
	var tw = create_tween().set_trans(Tween.TRANS_CUBIC)
	tw.tween_property(Beam, "scale:x", 1, grow_time/2.0)
	
	var tween_beam = create_tween().set_trans(Tween.TRANS_SINE).set_loops()
	tween_beam.pause()
	tween_beam.tween_property(Beams[0], "scale:x", 0.8, shrink_time/2)
	tween_beam.tween_property(Beams[0], "scale:x", 1.0, shrink_time/2)
	
	var tw_move = create_tween()
	tw_move.tween_property(self, "position", Vector2.UP.rotated(rotation) * 1000, 1.0).as_relative()
	tw_move.tween_callback(tween_beam.play)
	
	var tw_remove = create_tween()
	tw_remove.tween_interval(duration)
	tw_remove.set_parallel()
	tw_remove.tween_callback(tween_beam.kill)
	tw_remove.tween_property(Beam, "modulate:a", 0, shrink_time).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tw_remove.tween_property(Collision, "scale:x", 0, shrink_time)
	tw_remove.tween_callback(Collision.queue_free).set_delay(shrink_time/2.0)
	tw_remove.tween_property(Beam, "scale:x", 0, shrink_time)
	tw_remove.chain().tween_callback(queue_free).set_delay(1.7)
	


