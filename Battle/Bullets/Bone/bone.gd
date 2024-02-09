class_name Bone extends Bullet

@export var collision_margin: float = 4

var bone_width: float

func _ready() -> void:
	assert("size" in Collision.shape)
	assert("size" in Sprite)
	bone_width = Collision.shape.size.x
	Collision.shape = RectangleShape2D.new()


func _process(_delta: float) -> void:
	Collision.position.y = Sprite.size.y/2.0
	Collision.shape.size = Vector2(bone_width, Sprite.size.y - collision_margin)

func fire(target: Vector2, movement_type: int, speed: float = 100.0, mode: int = MODE_WHITE) -> void:
	damage_mode = mode
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

func queue_fire(delay: float,target: Vector2, movement_type: int, speed: float = 100.0, mode: int = MODE_WHITE) -> void:
	if velocity_tween and velocity_tween.is_valid() and velocity_tween.is_running():
		await velocity_tween.finished
	target_position = target
	var distance: Vector2 = target_position - global_position
	match movement_type:
		MOVEMENT_VELOCITY:
			await get_tree().create_timer(delay, false).timeout
			distance = target_position - global_position
			@warning_ignore("int_as_enum_without_cast")
			fire_mode = movement_type
			velocity = speed * distance.normalized()
			set("damage_mode", mode)
		MOVEMENT_TWEEN:
			velocity_tween = create_tween().set_ease(TweenEase).set_trans(TweenTrans)
			velocity_tween.tween_callback(set.bind("damage_mode", mode)).set_delay(delay)
			velocity_tween.tween_callback(set.bind("fire_mode", movement_type))
			velocity_tween.tween_property(self, "position", distance, distance.length() / speed).as_relative()

