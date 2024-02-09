class_name Bone extends Bullet

@export var collision_margin: float = 4

var bone_width: float
@onready var SpriteRect: NinePatchRect = get_node(sprite_path)

func _ready() -> void:
	assert("size" in Collision.shape)
	bone_width = Collision.shape.size.x
	Collision.shape = RectangleShape2D.new()


func _process(_delta: float) -> void:
	Collision.position.y = SpriteRect.size.y/2.0
	Collision.shape.size = Vector2(bone_width, SpriteRect.size.y - collision_margin)

func fire(target: Vector2, movement_type: int, speed: float = 100.0) -> Bone:
	#damage_mode = mode
	target_position = target
	var distance: Vector2 = target_position - global_position
	@warning_ignore("int_as_enum_without_cast")
	fire_mode = movement_type
	match fire_mode:
		MOVEMENT_VELOCITY:
			velocity = speed * distance.normalized()
		MOVEMENT_TWEEN:
			velocity_tween = create_tween().set_ease(TweenEase).set_trans(TweenTrans)
			velocity_tween.tween_property(self, "position", distance, distance.length() / speed).as_relative()
	return self

func queue_fire(delay: float,target: Vector2, movement_type: int, speed: float = 100.0) -> Bone:
	_await_fire(fire.bind(target, movement_type, speed),delay)
	return self

func _await_fire(fire_call: Callable, delay: float):
	if velocity_tween and velocity_tween.is_running(): await velocity_tween.finished
	var tw := create_tween()
	tw.tween_interval(delay)
	tw.tween_callback(fire_call)
	
var h_tween: Tween

func tween_height(new_height: float, time: float) -> PropertyTweener:
	if h_tween and h_tween.is_valid(): h_tween.kill()
	h_tween = create_tween()
	return h_tween.tween_property(SpriteRect, "size:y", new_height, time)
	
