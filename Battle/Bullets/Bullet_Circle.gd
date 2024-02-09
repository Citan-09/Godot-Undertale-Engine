extends BattleObject
class_name BulletCircle

var bullets: Array[Node] = []
var currentangle: float = 0.0
const rottime: float = 1.0

enum {
	FADE_AT_CENTER,
	FADE_OFF_SCREEN
}
class BulletCircleArgs:
	var _bullet: PackedScene
	var amount: int = 10
	var radius: float = 30.0
	var spawn_time: float = 1.0
	var delay: float = 0.5
	var speed: float = 200.0
	var bullet_mode := Bullet.MODE_WHITE
	var destroy_mode: int = FADE_AT_CENTER
	
	func set_delay(del: float) -> BulletCircleArgs:
		delay = del
		return self
	
	func set_damage_mode(damage_mode := bullet_mode) -> BulletCircleArgs:
		bullet_mode = damage_mode
		return self
	
	func set_destroy_time(new_destroy_mode := FADE_AT_CENTER) -> BulletCircleArgs:
		destroy_mode = new_destroy_mode
		return self
	
	func _init(_bullet: PackedScene, amount: int = 10, radius: float = 30.0, spawn_time: float = 1.0, speed: float = 200.0) -> void:
		self._bullet = _bullet
		self.amount = amount
		self.radius = radius
		self.spawn_time = spawn_time
		self.speed = speed



#func bullet_circle(_bullet: PackedScene, amount: int = 10, radius: float = 30.0, spawn_time: float = 1.0, delay: float = 0.5, speed: float = 200.0, bullet_mode: int = Bullet.MODE_WHITE, destroy_mode: int = FADE_AT_CENTER) -> void:
func bullet_circle(_bullet: PackedScene, amount: int = 10, radius: float = 30.0, spawn_time: float = 1.0, speed: float = 200.0) -> BulletCircleArgs:
	var obj: BulletCircleArgs = BulletCircleArgs.new(_bullet, amount, radius, spawn_time, speed)
	_fire_circle.call_deferred(obj)
	return obj

func _fire_circle(obj: BulletCircleArgs):
	currentangle = rotation_degrees
	for i in obj.amount:
		var current: Node = obj._bullet.instantiate()
		$Bullets.add_child(current)
		bullets.append(current)
		current.position = Vector2(sin(deg_to_rad(currentangle)), cos(deg_to_rad(currentangle))) * obj.radius
		current.fire(global_position, Bullet.MOVEMENT_VELOCITY, 0.0).set_damage_mode(obj.bullet_mode)
		currentangle += 360.0 / float(obj.amount)
		if $Spawn_Sound.get_playback_position() > 0.08 or !$Spawn_Sound.playing: $Spawn_Sound.play()
		await get_tree().create_timer(obj.spawn_time / obj.amount, false).timeout
	await get_tree().create_timer(obj.delay, false).timeout
	refresh_bullets()
	for current in bullets:
		current.fire(global_position, Bullet.MOVEMENT_VELOCITY, obj.speed).set_damage_mode(obj.bullet_mode)
	if obj.destroy_mode == FADE_AT_CENTER:
		await get_tree().create_timer(obj.radius / obj.speed, false).timeout
		fade()

func refresh_bullets() -> void:
	bullets = $Bullets.get_children()

func fade() -> void:
	refresh_bullets()
	for i in bullets:
		i.fade()

