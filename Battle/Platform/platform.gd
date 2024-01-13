extends BattleObjectControl
class_name Platform

var platform_mode: modes = modes.GREEN

enum modes{
	GREEN,
	PINK,
}


var colors: Array[Color] = [
	Color.LIME_GREEN,
	Color.DEEP_PINK,
]

@onready var colored_platform = $Platform
@onready var platform_col = $StaticBody2D
@onready var Collision = $StaticBody2D/CollisionShape2D

func _ready():
	Collision.shape = RectangleShape2D.new()
	Collision.shape.size.y = 6


func _physics_process(delta):
	colored_platform.self_modulate = colors[platform_mode]
	match platform_mode:
		modes.GREEN:
			platform_col.constant_linear_velocity = velocity
		modes.PINK:
			platform_col.constant_angular_velocity = Vector2.ZERO
	if velocity:
		position += velocity * delta


func fire(target_position: Vector2, length: float = 40, speed: float = 100.0, fire_mode: fire_modes = fire_modes.TWEEN, plat_mode: modes = modes.GREEN):
	self.size.x = length
	Collision.shape.size.x = length
	Collision.position.x = length/2.0
	var distance = target_position - position
	platform_mode = plat_mode
	print(distance)
	match fire_mode:
		fire_modes.VELOCITY:
			velocity = speed * distance.normalized()
		fire_modes.TWEEN:
			velocity_tween = create_tween().set_ease(TweenEase).set_trans(TweenTrans)
			velocity_tween.tween_property(self, "position", distance, distance.length() / speed).as_relative()
			velocity_tween.play()
	

