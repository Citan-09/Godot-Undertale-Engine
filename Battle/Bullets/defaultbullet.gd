extends CharacterBody2D
class_name bullet

var target_position := Vector2.ZERO
var fire_mode = fire_modes.VELOCITY
var velocity_tween :Tween
@export var TweenTrans := Tween.TRANS_QUAD
@export var TweenEase := Tween.EASE_IN_OUT
## Bullet stats (kr_amount only works if kr is enabled on the battle).
@export var stats = {
	"damage": 1,
	"iframe_grant": 50,
	"kr_amount": 5,
}
@export var delete_upon_hit = true

@onready var Area = $Area2D
@onready var Collision = $Area2D/Collision
@onready var Sprite = $Sprite

enum fire_modes{
	VELOCITY,
	TWEEN
}
var damage_mode : damage_modes = damage_modes.WHITE
enum damage_modes{
	WHITE,
	GREEN,
	BLUE,
	ORANGE,
}
var colors :Array[Color]= [
	Color.WHITE,
	Color.GREEN,
	Color.DODGER_BLUE,
	Color.ORANGE,
]


var overlapping_areas =[]
func _physics_process(delta: float) -> void:
	Sprite.modulate = colors[damage_mode]
	Collision.debug_color = Sprite.modulate
	Collision.debug_color.a = 0.3
	Area.damage_mode = damage_mode
	if fire_mode == fire_modes.VELOCITY:
		move_and_slide()
	if Area.monitoring:
		overlapping_areas = Area.get_overlapping_areas() 
		for i in overlapping_areas:
			if i.is_in_group("player") and (damage_mode <= damage_modes.GREEN) and delete_upon_hit:
				_on_hit_player()

func _on_hit_player():
	queue_free()

func fire(target : Vector2,movement_type : fire_modes,speed : float = 100.0,mode : damage_modes = damage_modes.WHITE):
	damage_mode = mode
	target_position = target
	var distance : Vector2 = target_position - global_position
	fire_mode = movement_type
	match fire_mode:
		fire_modes.VELOCITY:
			velocity = speed * distance.normalized()
		fire_modes.TWEEN:
			velocity_tween = create_tween()
			velocity_tween.tween_property(self,"position",distance,distance.length()/speed).as_relative()

func fade():
	var fadetw = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	fadetw.tween_property(self,"modulate:a",0,0.5)
	Area.monitorable = false
	Area.monitoring = false
	fadetw.tween_callback(queue_free)


func _on_exit_screen() -> void:
	if velocity_tween and velocity_tween.is_valid() or velocity:
		await get_tree().create_timer(0.5,false).timeout
		queue_free()
