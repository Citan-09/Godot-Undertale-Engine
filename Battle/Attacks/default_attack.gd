extends AttackBase
class_name default_attack

func start_attack():
	enemy_attacker.throw(Vector2.DOWN)
	for i in 4:
		if i % 2 == 1:
			Box.change_size(Vector2(-40, 0), true)
		for l in i:
			var clone = bullet1.instantiate()
			clone.position = Vector2(120, 380 - l * 20)
			add_bullet(clone)
			clone.fire(Vector2(820, 380 - l * 14), bullet.fire_modes.TWEEN, 120)

			clone = bullet1.instantiate()
			clone.position = Vector2(520, 380 - l * 20)
			add_bullet(clone)
			clone.fire(Vector2(-240, 380 - l * 14), bullet.fire_modes.TWEEN, 120)
		await get_tree().create_timer(0.6 + i / 10.0, false).timeout
	var b
	var b2
	for i in 2:
		b = bone.instantiate()
		add_bullet(b)
		b.position = Vector2(120, 400)
		b.rotation = 3 * PI / 4.0
		b.fire(Vector2(420, 400), bullet.fire_modes.TWEEN, 160.0)
		var bt = b.create_tween().set_trans(b.TweenTrans).set_ease(b.TweenEase).set_parallel()
		bt.tween_property(b.Sprite, "size:y", 70- i * 5, 1.6)
		bt.tween_property(b, "rotation", PI, 2)
		bt.chain().tween_property(b.Sprite, "size:y", 20, 0.7).as_relative()
		bt.tween_property(b, "rotation", - PI / 6.0, 1).as_relative()
		b.queue_fire(0.5, Vector2(20, 380), bullet.fire_modes.TWEEN, 190.0)

		b2 = bone.instantiate()
		add_bullet(b2)
		b2.position = Vector2(520, 400)
		b2.rotation = PI + PI / 4.0
		b2.fire(Vector2(220, 400), bullet.fire_modes.TWEEN, 160.0)
		var b2t = b2.create_tween().set_trans(b2.TweenTrans).set_ease(b2.TweenEase).set_parallel()
		b2t.tween_property(b2.Sprite, "size:y", 70- i * 5, 1.6)
		b2t.tween_property(b2, "rotation", PI, 2)
		b2t.chain().tween_property(b2.Sprite, "size:y", 20, 0.7).as_relative()
		b2t.tween_property(b2, "rotation", PI / 6.0, 1).as_relative()
		b2.queue_fire(0.5, Vector2(620, 380), bullet.fire_modes.TWEEN, 190.0)
		await get_tree().create_timer(1.25, false).timeout
	await get_tree().create_timer(2.4, false).timeout
	var plat = platform.instantiate()
	add_bullet(plat)
	plat.position = Vector2(300, 120)
	plat.fire(Vector2(300, 330), 40, 160.0)
	await get_tree().create_timer(0.6, false).timeout
	var spike = bone_spike.instantiate()
	add_bullet(spike)
	spike.position = Vector2(600, 400)
	spike.rotation = PI
	spike.fire(Vector2(600, 60), 0.5, 1)
	await get_tree().create_timer(1.3, false).timeout
	plat.fire(Vector2(300, 600), 40, 80.0)
	Soul.set_mode(Soul.RED)
	await Box.change_anchor(Box.RELATIVE_CENTER, Vector2(0, -50), Vector2(0, 100), true, true)
	for i in 7:
		if i % 2 == 0:
			var clone = blaster.instantiate()
			add_bullet(clone, false)
			clone.position = Vector2(Soul.position.x, -100)
			clone.fire(Vector2(Soul.position.x, 100), 1.5, 0.7, 0.2)
		var circle = bullet_circle.instantiate()
		add_bullet(circle, false)
		circle.bullet_circle(bullet1, 6, 80, 0.6, 0.1, 250, bullet.damage_modes.WHITE)
		if i % 2 == 0:
			circle.rotation_degrees += 90
		circle.position = Soul.position
		await get_tree().create_timer(0.8, false).timeout
	await get_tree().create_timer(1.2, false).timeout
	for i in 4:
		var circle = bullet_circle.instantiate()
		add_bullet(circle, false)
		circle.position = Soul.position
		circle.bullet_circle(bullet1, 30, 80, 0.5, 0.1, 100, bullet.damage_modes.BLUE if i % 2 == 0 else bullet.damage_modes.ORANGE, BulletCircle.destroy_modes.OFF_SCREEN)
		await get_tree().create_timer(1, false).timeout
	await get_tree().create_timer(1.5, false).timeout
	var circle = bullet_circle.instantiate()
	add_bullet(circle, false)
	circle.position = Soul.position
	circle.bullet_circle(bullet1, 30, 80, 1, 2, 60, bullet.damage_modes.GREEN, BulletCircle.destroy_modes.OFF_SCREEN)
	await get_tree().create_timer(4.5, false).timeout
	end_attack()
