extends Node2D

func _input(event: InputEvent) -> void:
	if event is InputEventMouse and event.is_pressed():
		pass


func _ready() -> void:
	$Timer.start()


func _on_timer_timeout() -> void:
	$Timer.start(lerpf($Timer.wait_time, 0.005, 0.06))
	var clone = preload("res://Battle/Bullets/Blaster/blaster.tscn").instantiate() as Blaster
	add_child(clone)
	clone.rotation = fmod(Time.get_unix_time_from_system() * 2.5, TAU)
	clone.position = Vector2(320,240) + Vector2.UP.rotated(clone.rotation) * 500.0
	clone.fire(Vector2(320,240) + Vector2.UP.rotated(clone.rotation) * 200.0, 2, 0.8, 0.1, 0)
