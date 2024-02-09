extends CanvasLayer

var target: Vector2

func transistion() -> void:
	$Black/Soul.position = Global.player_position
	$noise.play()
	await get_tree().create_timer(0.08, false).timeout
	for i in 2:
		$Black.hide()
		await get_tree().create_timer(0.08, false).timeout
		$Black.show()
		$noise.play()
		await get_tree().create_timer(0.08, false).timeout

	$drop.play()
	var tw := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tw.tween_callback($Black/Soul/Ghost.set.bind("emitting", true))
	tw.tween_property($Black/Soul, "position", target, 0.8).set_delay(0.07)
	tw.tween_property($Black/Soul, "modulate:a", 0, 0.3)
	await tw.finished
	queue_free()



