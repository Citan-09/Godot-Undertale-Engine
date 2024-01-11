extends AttackBase
class_name default_attack

func start_attack():
	enemy_attacker.throw(Vector2.DOWN)
	for i in 5:
		for l in i:
			var clone = bullet1.instantiate()
			clone.position = Vector2(120,380 - l * 20)
			add_bullet(clone)
			clone.fire(Vector2(820,380 - l * 14),bullet.fire_modes.TWEEN,120)
			
			clone = bullet1.instantiate()
			clone.position = Vector2(520,380 - l * 20)
			add_bullet(clone)
			clone.fire(Vector2(-240,380 - l * 14),bullet.fire_modes.TWEEN,120)
		await get_tree().create_timer(1.0 + i /10.0,false).timeout
	await get_tree().create_timer(1.25,false).timeout
	Soul.set_mode(Soul.RED)
	await Box.change_anchor(Box.RELATIVE_CENTER,Vector2(0,-50),Vector2(0,100),true,true)
	for i in 7:
		await get_tree().create_timer(0.8,false).timeout
		var circle = bullet_circle.instantiate()
		add_bullet(circle,false)
		circle.bullet_circle(bullet1,6,80,0.6,0.1,250,bullet.damage_modes.WHITE)
		if i % 2 ==0:
			circle.rotation_degrees += 90
		circle.position = Soul.position
	await get_tree().create_timer(1.2,false).timeout
	for i in 4:
		var circle = bullet_circle.instantiate()
		add_bullet(circle,false)
		circle.position = Soul.position
		circle.bullet_circle(bullet1,30,80,0.5,0.1,100,bullet.damage_modes.BLUE if i % 2 == 0 else bullet.damage_modes.ORANGE,BulletCircle.destroy_modes.OFF_SCREEN)
		await get_tree().create_timer(1,false).timeout
	await get_tree().create_timer(1.5,false).timeout
	var circle = bullet_circle.instantiate()
	add_bullet(circle,false)
	circle.position = Soul.position
	circle.bullet_circle(bullet1,30,80,1,2,60,bullet.damage_modes.GREEN,BulletCircle.destroy_modes.OFF_SCREEN)
	await get_tree().create_timer(4.5,false).timeout
	end_attack()
