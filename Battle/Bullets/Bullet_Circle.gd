extends BattleObject
class_name BulletCircle

var bullets: Array[Node] = []
var currentangle = 0.0
var rottime = 1.0
enum destroy_modes {
	CENTER,
	OFF_SCREEN
}
func bullet_circle(_bullet: PackedScene, amount: int = 10, radius: float = 30.0, spawn_time = 1.0, delay: float = 0.5, speed: float = 200.0, bullet_mode: bullet.damage_modes = bullet.damage_modes.WHITE, destroy_mode: destroy_modes = destroy_modes.CENTER):
	currentangle = rotation_degrees
	for i in amount:
		var current = _bullet.instantiate()
		$Bullets.add_child(current)
		bullets.append(current)
		current.position = Vector2(sin(deg_to_rad(currentangle)), cos(deg_to_rad(currentangle))) * radius
		current.fire(global_position, bullet.fire_modes.VELOCITY, 0.0, bullet_mode)
		currentangle += 360.0 / float(amount)
		if $Spawn_Sound.get_playback_position() > 0.08 or !$Spawn_Sound.playing: $Spawn_Sound.play()
		await get_tree().create_timer(spawn_time / amount, false).timeout
	await get_tree().create_timer(delay, false).timeout
	refresh_bullets()
	for current in bullets:
		current.fire(global_position, bullet.fire_modes.VELOCITY, speed, bullet_mode)
	if destroy_mode == destroy_modes.CENTER:
		await get_tree().create_timer(radius / speed, false).timeout
		fade()


func bullet_circle_rotate(_bullet: PackedScene, amount: int = 10, radius: float = 30.0, spawn_time = 1.0, delay: float = 0.5, speed: float = 200.0, bullet_mode: bullet.damage_modes = bullet.damage_modes.WHITE, destroy_mode: destroy_modes = destroy_modes.CENTER):
	currentangle = rotation_degrees
	for i in amount:
		var current = _bullet.instantiate()
		current.fire(global_position, bullet.fire_modes.VELOCITY, 0.0, bullet_mode)
		add_child(current)
		bullets.append(current)
		current.position = Vector2(sin(deg_to_rad(currentangle)), cos(deg_to_rad(currentangle))) * radius
		currentangle += 360.0 / float(amount)
		if $Spawn_Sound.get_playback_position() > 0.08 or !$Spawn_Sound.playing: $Spawn_Sound.play()
		await get_tree().create_timer(spawn_time / amount, false).timeout
	await get_tree().create_timer(delay, false).timeout
	refresh_bullets()
	var tw = create_tween()
	tw.tween_property(self, "rotation_degrees", 360, rottime).as_relative()
	for current in bullets:
		current.fire(global_position, bullet.fire_modes.VELOCITY, speed, bullet_mode)
	if destroy_mode == destroy_modes.OFF_SCREEN:
		await get_tree().create_timer(640.0 / speed, false).timeout
		fade()
	if destroy_mode == destroy_modes.CENTER:
		await get_tree().create_timer(radius / speed, false).timeout
		fade()

func refresh_bullets():
	bullets = $Bullets.get_children()

func fade():
	refresh_bullets()
	for i in bullets:
		i.fade()

