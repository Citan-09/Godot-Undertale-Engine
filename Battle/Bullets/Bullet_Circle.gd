extends BattleObject
class_name BulletCircle

var bullets: Array[Node] = []
var currentangle: float = 0.0
const rottime: float = 1.0

enum {
	FADE_AT_CENTER,
	FADE_OFF_SCREEN
}

func bullet_circle(_bullet: PackedScene, amount: int = 10, radius: float = 30.0, spawn_time: float = 1.0, delay: float = 0.5, speed: float = 200.0, bullet_mode: int = Bullet.MODE_WHITE, destroy_mode: int = FADE_AT_CENTER) -> void:
	currentangle = rotation_degrees
	for i in amount:
		var current: Node = _bullet.instantiate()
		$Bullets.add_child(current)
		bullets.append(current)
		current.position = Vector2(sin(deg_to_rad(currentangle)), cos(deg_to_rad(currentangle))) * radius
		current.fire(global_position, Bullet.MOVEMENT_VELOCITY, 0.0, bullet_mode)
		currentangle += 360.0 / float(amount)
		if $Spawn_Sound.get_playback_position() > 0.08 or !$Spawn_Sound.playing: $Spawn_Sound.play()
		await get_tree().create_timer(spawn_time / amount, false).timeout
	await get_tree().create_timer(delay, false).timeout
	refresh_bullets()
	for current in bullets:
		current.fire(global_position, Bullet.MOVEMENT_VELOCITY, speed, bullet_mode)
	if destroy_mode == FADE_AT_CENTER:
		await get_tree().create_timer(radius / speed, false).timeout
		fade()


func bullet_circle_rotate(_bullet: PackedScene, amount: int = 10, radius: float = 30.0, spawn_time: float = 1.0, delay: float = 0.5, speed: float = 200.0, bullet_mode: int = Bullet.MODE_WHITE, destroy_mode: int = FADE_AT_CENTER) -> void:
	currentangle = rotation_degrees
	for i in amount:
		var current: Node = _bullet.instantiate()
		current.fire(global_position, Bullet.MOVEMENT_VELOCITY, 0.0, bullet_mode)
		add_child(current)
		bullets.append(current)
		current.position = Vector2(sin(deg_to_rad(currentangle)), cos(deg_to_rad(currentangle))) * radius
		currentangle += 360.0 / float(amount)
		if $Spawn_Sound.get_playback_position() > 0.08 or !$Spawn_Sound.playing: $Spawn_Sound.play()
		await get_tree().create_timer(spawn_time / amount, false).timeout
	await get_tree().create_timer(delay, false).timeout
	refresh_bullets()
	var tw := create_tween()
	tw.tween_property(self, "rotation_degrees", 360, rottime).as_relative()
	for current in bullets:
		current.fire(global_position, Bullet.MOVEMENT_VELOCITY, speed, bullet_mode)
	if destroy_mode == FADE_OFF_SCREEN:
		await get_tree().create_timer(640.0 / speed, false).timeout
		fade()
	if destroy_mode == FADE_AT_CENTER:
		await get_tree().create_timer(radius / speed, false).timeout
		fade()

func refresh_bullets() -> void:
	bullets = $Bullets.get_children()

func fade() -> void:
	refresh_bullets()
	for i in bullets:
		i.fade()

