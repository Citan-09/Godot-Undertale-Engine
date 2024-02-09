extends BattleObjectControl
class_name Platform

var platform_mode: modes = modes.GREEN

enum modes {
	GREEN,
	PINK,
}


var colors: Array[Color] = [
	Color("009618"),
	Color("b700b8"),
]

@onready var colored_platform: NinePatchRect = $Platform
@onready var platform_col: StaticBody2D = $StaticBody2D
@onready var Collision: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var CollisionShape := Collision.shape as RectangleShape2D

func _ready() -> void:
	CollisionShape = RectangleShape2D.new()
	CollisionShape.size.y = 10


func _physics_process(delta: float) -> void:
	colored_platform.self_modulate = colors[platform_mode]
	match platform_mode:
		modes.GREEN:
			platform_col.constant_linear_velocity = velocity
		modes.PINK:
			platform_col.constant_linear_velocity = Vector2.ZERO
	if velocity:
		position += velocity * delta


func fire(target_position: Vector2, length: float = 40, speed: float = 100.0, fire_mode: fire_modes = fire_modes.TWEEN, plat_mode: modes = modes.GREEN) -> void:
	self.size.x = length
	CollisionShape.size.x = length
	Collision.position.x = length / 2.0
	var distance := target_position - position
	platform_mode = plat_mode
	match fire_mode:
		fire_modes.VELOCITY:
			velocity = speed * distance.normalized()
		fire_modes.TWEEN:
			velocity_tween = create_tween().set_ease(TweenEase).set_trans(TweenTrans)
			velocity_tween.tween_property(self, "position", distance, distance.length() / speed).as_relative()
			velocity_tween.play()


