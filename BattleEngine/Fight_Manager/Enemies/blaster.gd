extends Node2D
@onready var Camera = get_node("/root/main/Camera2D")
@export var time: float = 0.3
var duration = 0.15
@onready var beam = $Control
@onready var blaster = $Sprite
var mode = 0

func changemode():
	$Area2D.mode = mode
	match mode:
		0:
			self.modulate = Color.WHITE
		1:
			self.modulate = Color.DEEP_SKY_BLUE
		2:
			self.modulate = Color.CORAL
		3:
			self.modulate = Color.GREEN
func fire(posx = 0,posy= 0,rotate = null,width= null,delay= 0.4,color = 0):
	if color != null:
		mode = color
		changemode()
	$Load.play()
	var tweenpos = get_tree().create_tween()
	var tween2 = get_tree().create_tween()
	var tween3 = get_tree().create_tween()
	tweenpos.tween_property(self,"position",Vector2(posx,posy),time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	if rotate !=null:
		tween2.tween_property(self,"rotation_degrees",rotate+360,time/2)
	if width !=null:
		self.scale.x = width/2
		tween3.tween_property(self,"scale",Vector2(width,2),time/2)
	await get_tree().create_timer(time+delay - 0.5,false).timeout
	$sparkle.emitting= true
	$AnimationPlayer.play("start")
	var tween = get_tree().create_tween()
	tween.tween_property(self,"scale:y",1.2,0.2).set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self,"scale:y",2,0.15).set_trans(Tween.TRANS_QUINT)
	await get_tree().create_timer(0.3,false).timeout
	Camera.addshake(1)
	
	
	col.disabled = false
	beam.show()
	$Control/sparkle3.emitting = true
	tween3 = get_tree().create_tween()
	tween3.tween_property(beam,"size:y",5000,0.2).set_trans(Tween.TRANS_QUINT)
	tween2 = get_tree().create_tween()
	tween2.tween_property(beam,"size:x",24,0.2).set_trans(Tween.TRANS_QUINT)
	tween = get_tree().create_tween()
	tween.tween_property(beam,"position:x",-12,0.2).set_trans(Tween.TRANS_QUINT)
	playfire()
	escapefromscreen()
	$Fire.play()
	
func playfire():
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.play("fire")
	
var velocity = Vector2(0,0)
func escapefromscreen():
	var th = rotation
	var sect = int(th/90.0)%4
	match sect:
		0:
			velocity = Vector2(sin(th),-cos(th))
		1:
			velocity = Vector2(sin(th),-cos(th))
		2:
			velocity = Vector2(cos(th),-sin(th))
		3:
			velocity = Vector2(sin(th),-cos(th))
	velocity *= 640
	await get_tree().create_timer(duration,false).timeout
	var tween = get_tree().create_tween()
	var tween2 = get_tree().create_tween()
	var tween3 = get_tree().create_tween()
	var t = 0.4
	tween2.tween_property(beam,"position:x",0,t).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.tween_property(beam,"size:x",0,t).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween3.tween_property(beam,"modulate:a",0,t).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	await get_tree().create_timer(t-0.15,false).timeout
	col.queue_free()
	await $Fire.finished
	self.queue_free()
@onready var col = $Area2D/CollisionShape2D
func _ready():
	col.disabled = true
	beam.hide()
	col.shape = RectangleShape2D.new()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.position += velocity *delta
	if col != null:
		col.shape.size = Vector2(max(beam.size.x,0),beam.size.y)
		col.position = beam.position + beam.size/2
		
