extends StaticBody2D

var greensprite = load("res://Shared/misc/greenplat.png")
var pinksprite = load("res://Shared/misc/pinkplat.png")
var mode = "green"

var vel = Vector2(0,0)
var time = 1
var trans = Tween.TRANS_CUBIC

func cast(posx,posy,tx,ty,color,length):
	$CollisionShape2D.shape = RectangleShape2D.new()
	self.global_position = Vector2(posx,posy)
	$NinePatchRect.size = Vector2(length,12)
	var t = get_tree().create_tween()
	t.tween_property(self,"position",Vector2(tx,ty),time).set_trans(trans)
	await t.finished
	changemode(color)
func update(velx=0,vely = 0,color = null):
	vel = Vector2(velx,vely)
	#var t = get_tree().create_tween()
	#t.tween_property(self,"vel",Vector2(velx,vely),1).set_trans(trans).set_ease(Tween.EASE_IN)
	if color !=null:
		$Mode.play()
		changemode(color)

func changemode(change):
	mode = change
	if change == "green":
		self.constant_linear_velocity = vel
		$NinePatchRect.texture = greensprite
	if change == "pink":
		self.constant_linear_velocity = Vector2.ZERO
		$NinePatchRect.texture = pinksprite
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$NinePatchRect.position = -$NinePatchRect.size/2
	$CollisionShape2D.shape.size= Vector2($NinePatchRect.size.x+2,2)
	self.position += vel * delta
	if abs(self.position.x) > 800 or abs (self.position.y) > 600:
		self.queue_free()
