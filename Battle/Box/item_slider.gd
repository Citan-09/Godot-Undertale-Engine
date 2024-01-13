extends Control
class_name ItemSlider

@export var value := 0
@export var offset: float = 0
@export var step_size: float = 1

@export var grabber: NodePath = ^"Grabber"
@onready var Grabber = get_node(grabber)

const speed = 40
func _process(delta):
	Grabber.position.y = lerpf(Grabber.position.y, offset + step_size * value, delta * speed)
