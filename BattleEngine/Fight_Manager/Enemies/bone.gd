extends Area2D
class_name BoneBullet

@export var Sprite = "res://BattleEngine/Fight_Manager/Enemies/BoneSans.png"
var tag = ""
var vel : Vector2 = Vector2(0,0)
var damage = 1
@onready var bone = $Node2D/NinePatchRect
@onready var col = $CollisionShape2D
var sizeto = 80
var mode = 0 #(0 = white, 1 = blue, 2 = orange, 3 = healing)
var endx = 0

var limit = 0 #USE IF ROTATING BOX
var dir # THIS IS NEEDED FOR LIMITS TO WORK

var offset = Vector2.ZERO
var trans = Tween.TRANS_QUAD
var ease = Tween.EASE_OUT
var time = 0.7
var defaultoffset
var tweensize:Tween
var type = ""
var count = false
var normalh
var x = 0
var p = 1
var a = 1
var o = 0

func setwave(normalheight:float=sizeto,wtype="sine",wp=10.0,wa=1.0,wo=0.0):
	if tweensize:
		tweensize.custom_step(10000)
		tweensize.kill()
	count = true
	type = wtype
	normalh = float(normalheight)
	p = float(wp)
	a = float(wa)
	o = float(wo)

func _ready():
	defaultoffset = $Node2D.position
	col.shape = RectangleShape2D.new()
	if Sprite:
		bone.texture = load(Sprite)
	

func _physics_process(delta):
	if count:
		x+= delta
		match type:
			"sine":
				bone.size.y =normalh+ Extra.sine(x,p,a,o)
			"triangle":
				bone.size.y =normalh+ Extra.triangle(x,p,a,o)
		sizeto=bone.size.y
	
	self.position += vel * delta
	if abs(self.global_position.x- 320)  < endx:
		var t =get_tree().create_tween()
		t.tween_property(self,"vel:x",-vel.x,1).set_ease(Tween.EASE_IN_OUT)
		
func changemode():
	match mode:
		0:
			bone.modulate = Color.WHITE
		1:
			bone.modulate = Color.DEEP_SKY_BLUE
		2:
			bone.modulate = Color.CORAL
		3:
			bone.modulate = Color.GREEN
func _process(delta):
	if $Node2D:
		$Node2D.position = Vector2(offset.x,offset.y)+defaultoffset
	check_onscreen()
	#if bone.size.y != sizeto && self.visible:
	col.shape.size = Vector2(bone.size.x - 7,bone.size.y - 6)
	col.position = bone.position + bone.size/2 + Vector2(offset.x+0.5,offset.y)
func check_onscreen():
	if limit:
		match dir:
			"left":
				if position.x < limit:
					self.queue_free()
			"right":
				if position.x > limit:
					self.queue_free()
			"down":
				if position.y > limit:
					self.queue_free()
			"up":
				if position.y < limit:
					self.queue_free()
	elif abs(self.position.x) > 800 or abs (self.position.y) > 600:
		self.get_parent().remove_child(self)
		self.queue_free()
func fire(velx = 300,vely= 0,size = null,color = null,otation = null,end = null):
	if color != null:
		self.mode = color
	self.show()
	self.vel.x = velx
	self.vel.y = vely
	if otation !=null:
		self.rotation_degrees = otation
	if end != null:
		self.endx = end
	changemode()
	if size != null:
		sizeto = size
		changesize(size)
func changesize(size = sizeto):
	tweensize = get_tree().create_tween()
	tweensize.bind_node(self)
	tweensize.tween_property(bone,"size:y",size,time).set_trans(trans).set_ease(ease)


func _on_nine_patch_rect_texture_changed():
	if Sprite == "res://BattleEngine/Fight_Manager/Enemies/BBonePapy.png":
		$Node2D.position.x = 0.5
	else:
		$Node2D.position.x = 1
