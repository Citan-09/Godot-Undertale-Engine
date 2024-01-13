extends bullet


func fire(target: Vector2, movement_type: fire_modes, speed: float = 100.0, mode: damage_modes = damage_modes.WHITE):
	damage_mode = mode
	target_position = target
	var distance: Vector2 = target_position - global_position
	fire_mode = movement_type
	match fire_mode:
		fire_modes.VELOCITY:
			velocity = speed * distance.normalized()
		fire_modes.TWEEN:
			velocity_tween = create_tween().set_ease(TweenEase).set_trans(TweenTrans)
			velocity_tween.tween_property(self, "position", distance, distance.length() / speed).as_relative()
			velocity_tween.play()


func queue_fire(delay: float,target: Vector2, movement_type: fire_modes, speed: float = 100.0, mode: damage_modes = damage_modes.WHITE):
	if velocity_tween and velocity_tween.is_valid() and velocity_tween.is_running():
		await velocity_tween.finished
	await get_tree().create_timer(delay, false).timeout
	fire(target, movement_type, speed, mode)


