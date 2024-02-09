class_name YellowBullet extends AnimatedSprite2D

const SPEED: int = 300
var velocity := Vector2.ZERO

func _physics_process(delta: float) -> void:
	position += velocity * delta


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area is BulletAreaYellowHittable:
		area._on_yellow_bullet_hit()
