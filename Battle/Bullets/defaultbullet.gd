class_name DefaultBullet extends Bullet


func fire(target: Vector2, movement_type: int, speed: float = 100.0) -> DefaultBullet:
	target_position = target
	var distance: Vector2 = target_position - global_position
	@warning_ignore("int_as_enum_without_cast")
	fire_mode = movement_type
	match fire_mode:
		MOVEMENT_VELOCITY:
			velocity = speed * distance.normalized()
		MOVEMENT_TWEEN:
			velocity_tween = create_tween().set_ease(TweenEase).set_trans(TweenTrans)
			velocity_tween.tween_property(self, "position", distance, distance.length() / speed).as_relative()
	return self


func queue_fire(delay: float, target: Vector2, movement_type: int, speed: float = 100.0) -> DefaultBullet:
	_await_fire(fire.bind(target, movement_type, speed),delay)
	return self

func _await_fire(fire_call: Callable, delay: float) -> DefaultBullet:
	if velocity_tween and velocity_tween.is_running(): await velocity_tween.finished
	var tw := create_tween()
	tw.tween_interval(delay)
	tw.tween_callback(fire_call)
	return self
