extends ParallaxBackground
@export var HeightFront = Vector2(60,120)
@export var HeightBack = Vector2(90,150)
@export var speed = 50.0
@export var color = Color.WHITE

@onready var Front = $Front/Bone
@onready var Back = $Back/Bone
# Called when the node enters the scene tree for the first time.
func _ready():
	Front.size.y = HeightFront.x
	Back.size.y = HeightBack.y
	var t = get_tree().create_tween().set_loops()
	t.set_trans(Tween.TRANS_ELASTIC)
	t.tween_property(Front,"size:y",HeightFront.y,1)
	t.tween_property(Front,"size:y",HeightFront.x,1)
	t.tween_interval(0)
	var t2 = get_tree().create_tween().set_loops()
	t2.set_trans(Tween.TRANS_ELASTIC)
	t2.tween_property(Back,"size:y",HeightBack.x,1)
	t2.tween_property(Back,"size:y",HeightBack.y,1)
	t.tween_interval(0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	Front.self_modulate = color
	Back.self_modulate = color
	self.scroll_base_offset.x -= speed*delta
