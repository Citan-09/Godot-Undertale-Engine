extends Area2D

var tag = ""
var mode = 0
var velocity:Vector2 = Vector2.ZERO

func fire(vx,vy):
	velocity = Vector2(vx,vy)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += velocity * delta
	
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
