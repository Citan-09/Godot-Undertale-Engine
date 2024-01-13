extends Control
@export var sizetime:float

# Called when the node enters the scene tree for the first time.
func _ready():
	#summonwarn(600,10,100,100,1,0)
	pass # Replace with function body.

func summonwarn(x,y,modx,mody,time:float,rot):
	$WARNING.play()
	self.rotation_degrees = rot
	var newsize = get_tree().create_tween()
	var newsize2 = get_tree().create_tween()
	newsize.tween_property(self,"size:x",x,sizetime).set_trans(Tween.TRANS_QUINT)
	newsize.tween_property(self,"size:y",y,sizetime).set_trans(Tween.TRANS_QUINT)
	position = Vector2(modx,mody) - Vector2(x,y)/2
	newsize2.tween_property($NinePatchRect,"modulate:a",0.9,sizetime*3).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN_OUT)
	await get_tree().create_timer(time).timeout
	queue_free()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.pivot_offset = self.size/2
