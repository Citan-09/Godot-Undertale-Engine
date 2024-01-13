extends Control
@export var sizetime:float

# Called when the node enters the scene tree for the first time.
func _ready():
	#summonwarn(100,100,1)
	pass # Replace with function body.

func summonwarn(posx,posy,time:float):
	$WARNING.play()
	self.position = Vector2(posx,posy)
	var tw = get_tree().create_tween()
	tw.tween_property($Sprite,"modulate:a",1,time/4)
	tw.tween_interval(time/2)
	tw.tween_property($Sprite,"modulate:a",0,time/4)
	tw.tween_callback(queue_free)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.pivot_offset = self.size/2
