extends CharacterBody2D
class_name bullet

signal shakeCamera(shake_amt: float)

var target_position := Vector2.ZERO
var fire_mode = fire_modes.VELOCITY
var velocity_tween: Tween
@export var TweenTrans := Tween.TRANS_QUAD
@export var TweenEase := Tween.EASE_IN_OUT
## Bullet stats (kr_amount only works if kr is enabled on the battle).
@export_group("Bullet Stats")
@export var damage: int = 5
@export var iframe_grant: int = 50
@export var kr_amount: int = 5
@export var delete_upon_hit = false
@export_group("")

@export var area_path = ^"Area2D"
@export var collision_path = ^"Area2D/CollisionShape2D"
@export var sprite_path = ^"Sprite"
@onready var Area: BulletArea = get_node(area_path)
@onready var Collision: CollisionShape2D = get_node(collision_path)
@onready var Sprite: Node = get_node(sprite_path)
@onready var this = $"."

enum fire_modes {
	VELOCITY,
	TWEEN
}

var damage_mode: damage_modes = damage_modes.WHITE

enum damage_modes {
	WHITE,
	GREEN,
	BLUE,
	ORANGE,
}

var colors: Array[Color] = [
	Color.WHITE,
	Color.GREEN,
	Color.DEEP_SKY_BLUE,
	Color.ORANGE,
]


var overlapping_areas = []

func _physics_process(delta: float) -> void:
	Sprite.modulate = colors[damage_mode]
	if is_instance_valid(Collision):
		Collision.debug_color = Sprite.modulate.blend(Color(0.8,0.0,0.0,0.33))
		Collision.debug_color.a = 0.2
	Area.damage_mode = damage_mode
	if fire_mode == fire_modes.VELOCITY:
		this.move_and_slide()
	if Area.monitoring:
		overlapping_areas = Area.get_overlapping_areas()
		for i in overlapping_areas:
			if i.is_in_group("player") and (damage_mode <= damage_modes.GREEN) and delete_upon_hit:
				_on_hit_player()

func _on_hit_player():
	queue_free()


func fade():
	var fadetw = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	fadetw.tween_property(self, "modulate:a", 0, 0.5)
	Area.monitorable = false
	Area.monitoring = false
	fadetw.tween_callback(queue_free)


func _on_exit_screen() -> void:
	if not velocity_tween or not velocity_tween.is_valid() or this.velocity:
		fade()
