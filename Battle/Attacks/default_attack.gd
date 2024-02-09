extends AttackBase
class_name default_attack

func start_attack() -> void:
	enemy_attacker.throw(Vector2.UP)
	await get_tree().create_timer(0.5, false).timeout
	enemy_attacker.throw(Vector2.RIGHT)
	await get_tree().create_timer(0.5, false).timeout
	enemy_attacker.throw(Vector2.LEFT)
	await get_tree().create_timer(0.5, false).timeout
	enemy_attacker.throw(Vector2.DOWN)
	for i in 4:
		if i % 2 == 1:
			Box.change_size(Vector2(-40, 0), true)
		for l in i:
			var clone: Node = bullet1.instantiate()
			clone.position = Vector2(120, 380 - l * 20)
			add_bullet(clone)
			clone.fire(Vector2(820, 380 - l * 14), Bullet.MOVEMENT_TWEEN, 120)

			clone = bullet1.instantiate()
			clone.position = Vector2(520, 380 - l * 20)
			add_bullet(clone)
			clone.fire(Vector2(-240, 380 - l * 14), Bullet.MOVEMENT_TWEEN, 120)
		await get_tree().create_timer(0.6 + i / 10.0, false).timeout
	var b: Bone
	var b2: Bone
	for i in 2:
		b = bone.instantiate()
		add_bullet(b)
		b.position = Vector2(120, 400)
		b.rotation = 3 * PI / 4.0
		b.fire(Vector2(420, 400), Bullet.MOVEMENT_TWEEN, 160.0)
		var bt := b.create_tween().set_trans(b.TweenTrans).set_ease(b.TweenEase).set_parallel()
		bt.tween_property(b.Sprite, "size:y", 70- i * 5, 1.6)
		bt.tween_property(b, "rotation", PI, 2)
		bt.chain().tween_property(b.Sprite, "size:y", 20, 0.7).as_relative()
		bt.tween_property(b, "rotation", - PI / 6.0, 1).as_relative()
		b.queue_fire(0.5, Vector2(20, 380), Bullet.MOVEMENT_TWEEN, 190.0)

		b2 = bone.instantiate()
		add_bullet(b2)
		b2.position = Vector2(520, 400)
		b2.rotation = PI + PI / 4.0
		b2.fire(Vector2(220, 400), Bullet.MOVEMENT_TWEEN, 160.0)
		var b2t := b2.create_tween().set_trans(b2.TweenTrans).set_ease(b2.TweenEase).set_parallel()
		b2t.tween_property(b2.Sprite, "size:y", 70- i * 5, 1.6)
		b2t.tween_property(b2, "rotation", PI, 2)
		b2t.chain().tween_property(b2.Sprite, "size:y", 20, 0.7).as_relative()
		b2t.tween_property(b2, "rotation", PI / 6.0, 1).as_relative()
		b2.queue_fire(0.5, Vector2(620, 380), Bullet.MOVEMENT_TWEEN, 190.0)
		await get_tree().create_timer(1.25, false).timeout
	await get_tree().create_timer(2.4, false).timeout
	var plat: Node = platform.instantiate()

	var spike: Node = bone_spike.instantiate()
	add_bullet(spike)
	spike.position = Vector2(0, 250)
	spike.fire(Vector2(600, 140), 1.3, 1, Bullet.MODE_BLUE)
	
	spike = bone_spike.instantiate()
	add_bullet(spike)
	spike.position = Vector2(601, 400)
	spike.rotation = PI
	spike.fire(Vector2(600, 60), 1, 1)
	
	add_bullet(plat)
	plat.position = Vector2(300, 120)
	plat.fire(Vector2(300, 330), 40, 160.0)
	
	await get_tree().create_timer(2.5, false).timeout
	plat.fire(Vector2(300, 600), 40, 80.0)
	Soul.set_mode(Soul.RED)
	await Box.change_position_size(Box.RELATIVE_CENTER, Vector2(0, -50), Vector2(0, 100), true, true)
	var circle: BulletCircle
	for i in 7:
		if i % 2 == 0:
			var clone: Node = blaster.instantiate()
			add_bullet(clone, Masking.ABSOLUTE)
			clone.position = Vector2(Soul.position.x, -100)
			clone.fire(Vector2(Soul.position.x, 100), 1.5, 0.7, 0.2)
		circle = bullet_circle.instantiate()
		add_bullet(circle, Masking.ABSOLUTE)
		circle.bullet_circle(bullet1, 6, 80, 0.6, 0.1, 250, Bullet.MODE_WHITE)
		if i % 2 == 0:
			circle.rotation_degrees += 90
		circle.position = Soul.position
		await get_tree().create_timer(0.8, false).timeout
	await get_tree().create_timer(1.2, false).timeout
	for i in 4:
		circle = bullet_circle.instantiate()
		add_bullet(circle, Masking.ABSOLUTE)
		circle.position = Soul.position
		circle.bullet_circle(bullet1, 30, 80, 0.5, 0.1, 100, Bullet.MODE_BLUE if i % 2 == 0 else Bullet.MODE_ORANGE, BulletCircle.FADE_OFF_SCREEN)
		await get_tree().create_timer(1, false).timeout
	await get_tree().create_timer(1.5, false).timeout
	circle = bullet_circle.instantiate()
	add_bullet(circle, Masking.ABSOLUTE)
	circle.position = Soul.position
	circle.bullet_circle(bullet1, 30, 80, 1, 2, 60, Bullet.MODE_GREEN, BulletCircle.FADE_OFF_SCREEN)
	await get_tree().create_timer(4.5, false).timeout
	Soul.set_mode(Soul.GREEN)
	var bl = quick_bullet(blaster, Vector2(320, 40), 0, Masking.ABSOLUTE) as Blaster
	bl.fire(Vector2(320, 90), 6, 0.8, 1)
	await get_tree().create_timer(1.8, false).timeout
	Box.set_webs(3)
	Soul.set_mode(Soul.PURPLE)
	await get_tree().create_timer(1.8, false).timeout
	Soul.set_mode(Soul.YELLOW)
	await get_tree().create_timer(1.8, false).timeout
	quick_bullet(bone, Vector2(320, 300), 180).Sprite.size.y = 50
	Soul.set_mode(Soul.CYAN)
	await get_tree().create_timer(1.8, false).timeout
	Soul.set_mode(Soul.ORANGE)
	await get_tree().create_timer(1.8, false).timeout
	end_attack()
