class_name CyanDetection extends Area2D

var can_move := false

@onready var Sprite = $Sprite2D
@onready var Glow = $Sprite2D/Glow


const SPEED: float = 0.4
const AMT: float = 0.2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	can_move = false
	Glow.emitting = false
	var areas: Array[Area2D] = get_overlapping_areas()
	for i: Area2D in areas:
		if i is BulletArea:
			Sprite.modulate.a = lerpf(Sprite.modulate.a, 1, delta * SPEED)
			can_move = true
			Glow.emitting = true
		else:
			Sprite.modulate.a = lerpf(Sprite.modulate.a, 0, delta * SPEED * 2)

