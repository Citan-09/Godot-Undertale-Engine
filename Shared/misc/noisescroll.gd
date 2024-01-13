extends ParallaxBackground
@export var speed = 500.0
@export var color = Color.WHITE

func _ready() -> void:
	$ParallaxLayer/TextureRect.modulate = color
func _process(delta: float) -> void:
	scroll_base_offset.x -= speed*delta
