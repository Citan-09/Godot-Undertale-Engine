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
	var speed: float
	var amount: int = 10
	var radius: float = 30.0
	var spawn_time: float = 1.0
	var delay: float = 0
	var destroy_mode: int = FADE_AT_CENTER
	var mode := Bullet.MODE_WHITE
	
	func set_delay(_delay: float) -> BulletCircleArgs:
		self.delay = _delay
		return self
	
	func set_mode(_mode := Bullet.MODE_WHITE) -> BulletCircleArgs:
		self.mode = _mode
		return self
	
	func set_destroy_time(_destroy_mode := FADE_AT_CENTER) -> BulletCircleArgs:
		self.destroy_mode = _destroy_mode
		return self
	
	@warning_ignore("shadowed_variable")
	func _init(_bullet: PackedScene, speed: float, amount: int = 10, radius: float = 30.0, spawn_time: float = 1.0) -> void:
		self.speed = speed
		self._bullet = _bullet
		self.amount = amount
		self.radius = radius
		self.spawn_time = spawn_time



#func bullet_circle(_bullet: PackedScene, amount: int = 10, radius: float = 30.0, spawn_time: float = 1.0, delay: float = 0.5, speed: float = 200.0, bullet_mode: int = Bullet.MODE_WHITE, destroy_mode: int = FADE_AT_CENTER) -> void:
func bullet_circle(_bullet: PackedScene, speed: float, amount: int = 10, radius: float = 30.0, spawn_time: float = 1.0) -> BulletCircleArgs:
	var obj: BulletCircleArgs = BulletCircleArgs.new(_bullet, speed, amount, radius, spawn_time)
	_fire_circle.call_deferred(obj)
	return obj

func _fire_circle(obj: BulletCircleArgs):
	currentangle = 0
	for i in obj.amount:
		var current: Node = obj._bullet.instantiate()
		$Bullets.add_child(current)
		bullets.append(current)
		current.position = Vector2(sin(deg_to_rad(currentangle)), cos(deg_to_rad(currentangle))) * obj.radius
		current.set_mode(obj.mode)
		currentangle += 360.0 / float(obj.amount)
		if $Spawn_Sound.get_playback_position() > 0.08 or !$Spawn_Sound.playing: $Spawn_Sound.play()
		await get_tree().create_timer(obj.spawn_time / obj.amount, false).timeout
	await get_tree().create_timer(obj.delay, false).timeout
	refresh_bullets()
	for current in bullets:
		current.fire(global_position, Bullet.MOVEMENT_VELOCITY, obj.speed)
	if obj.destroy_mode == FADE_AT_CENTER:
		await get_tree().create_timer(obj.radius / obj.speed, false).timeout
		fade()

func refresh_bullets() -> void:
	bullets = $Bullets.get_children()

func fade() -> void:
	refresh_bullets()
	for i in bullets:
		i.fade()

