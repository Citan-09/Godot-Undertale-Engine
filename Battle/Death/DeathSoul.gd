extends AnimatedSprite2D

@export_enum("HUMAN", "MONSTER") var soul_type: int = 0

var human_color := Color.RED
var monster_color := Color.WHITE

@export var camera_path := ^""
@onready var Camera: CameraFx = get_node(camera_path)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if soul_type:
		modulate = monster_color
		scale.y = -1
	else:
		modulate = human_color

func die() -> void:
	Camera.add_shake(0.5)
	animation = "death"
	$snap.play()
	await get_tree().create_timer(0.5, false).timeout
	$shards.emitting = true
	$shatter.play()
	self_modulate.a = 0
	Camera.add_shake(0.7)
	await get_tree().create_timer(2, false).timeout
