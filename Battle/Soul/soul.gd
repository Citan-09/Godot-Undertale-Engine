@icon("res://Battle/Soul/soul.png")
extends CharacterBody2D
class_name SoulBattle

var gravity_multiplier: float = 1
const jump := [8.0, 5.0, 2.5, 170.0]
const speed: float = 160
const gravity: float = 3.25

@export var soul_type := soul_types.SOUL_HUMAN
var mode := RED : set = set_mode_silent
var inputlist := Vector2.ZERO
var slow_down: int

var gravity_direction := Vector2.DOWN: set = set_gravity_direction_silent
@export_enum("ARROW_KEYS", "VELOCITY", "ARROW_KEYS_AND_MOVING") var special_bullet_mode: int = 0
@onready var sprites: Node2D = $Sprite
@onready var ghost: GPUParticles2D = $Sprite/Ghost
@onready var Shoot: AudioStreamPlayer = $Shoot
@onready var ModeChangeS: AudioStreamPlayer = $Ding
@onready var Main: BattleMain = $/root/main
@onready var HurtSound: AudioStreamPlayer = $Hurt
@onready var Area: Area2D = $Area2D


## SoulMode Stuff
var green_mode = preload("res://Battle/Soul/green_soul.tscn")
@onready var GreenShield: GreenShielding = green_mode.instantiate()

var yellow_bullet = preload("res://Battle/Soul/yellow_soul_bullet.tscn")

var cyan_detect = preload("res://Battle/Soul/cyan_detection.tscn")
@onready var CyanDetector: CyanDetection = cyan_detect.instantiate()

@onready var ModeNodes := {
	GREEN: GreenShield,
	CYAN: CyanDetector,
}

enum {
	RED,
	BLUE,
	ORANGE,
	YELLOW,
	GREEN,
	CYAN,
	PURPLE,

	DISABLE_MOVEMENT,
}

enum soul_types {
	SOUL_HUMAN = 0,
	SOUL_MONSTER = 2
}

var hiframes: float = 0.0
var iframes: float = 0.0
var invulnerable := false
var overlapping_areas: Array[Area2D] = []

signal shake_camera(amt: float)
func _ready() -> void:
	set_gravity_direction(Vector2.DOWN, false)
	modulate.a = 0
	set_physics_process(false)
	set_process(false)
	red()
	
var _able_tween: Tween

func _kill_able_tween():
	if _able_tween and _able_tween.is_valid(): _able_tween.kill()

func disable() -> void:
	if is_processing():
		_kill_able_tween()
		set_process(false)
		set_physics_process(false)
		_able_tween = create_tween()
		_able_tween.tween_property(self, "modulate:a", 0, 0.2)
		_able_tween.tween_callback(get_parent().remove_child.bind(self)).set_delay(0.05)

func _enter_tree() -> void:
	enable()
	motion = Vector2.ZERO
	velocity = Vector2.ZERO
	gravity_direction = Vector2.DOWN
	mode = DISABLE_MOVEMENT

func enable() -> void:
	if !is_processing():
		if !is_node_ready(): await ready
		_kill_able_tween()
		position = Vector2(320, 320)
		_able_tween = create_tween()
		_able_tween.tween_property(self, "modulate:a", 1, 0.2)
		_able_tween.tween_callback(set_process.bind(true))
		_able_tween.tween_callback(set_physics_process.bind(true))


func _physics_process(_delta: float) -> void:
	sprites.scale = Vector2.ONE
	if gravity_direction.x:
		motion.x = velocity.y
		motion.y = velocity.x * gravity_direction.x
	else:
		motion.y = velocity.y * gravity_direction.y
		motion.x = velocity.x
	
	up_direction = gravity_direction * -1
	match mode:
		RED:
			red()
		BLUE:
			blue()
		GREEN:
			green()
		YELLOW:
			yellow()
		PURPLE:
			purple()
		ORANGE:
			orange()
		CYAN:
			cyan()
		# Add more if you want:
	_motion_align_gravity_direction()
	overlapping_areas = Area.get_overlapping_areas()
	for i in overlapping_areas.size():
		check_bullet(overlapping_areas[i])


func _process(delta: float) -> void:
	var delta_frame: float = ProjectSettings.get_setting("max_fps", Engine.get_frames_per_second())
	iframes -= delta * delta_frame
	hiframes -= delta * delta_frame
	if iframes > 0:
		if int(iframes) % 8 == 0:
			self.modulate.a = 1
		elif int(iframes) % 8 == 4 and Global.settings["vfx"]:
			self.modulate.a = 0.6
	else:
		self.modulate.a = 1


func check_bullet(area: Area2D) -> void:
	if !invulnerable and area is BulletArea:
		if hiframes <= 0:
			match area.damage_mode:
				Bullet.MODE_GREEN:
					heal(area)
		if iframes <= 0:
			match area.damage_mode:
				Bullet.MODE_WHITE:
					hurt(area)
				Bullet.MODE_BLUE:
					if special_bullet_mode == 0 and !inputlist.is_zero_approx() or special_bullet_mode == 1 and velocity or special_bullet_mode == 2 and (!inputlist.is_zero_approx() and velocity):
						hurt(area)
				Bullet.MODE_ORANGE:
					if special_bullet_mode == 0 and !inputlist.is_zero_approx() or special_bullet_mode == 1 and not velocity or special_bullet_mode == 2 and not (!inputlist.is_zero_approx() and velocity):
						hurt(area)

func hurt(area: BulletArea) -> void:
	iframes = area.iframes
	Global.player_hp -= max(area.damage - Global.player_defense - Global.item_list[Global.equipment["weapon"]].defense_amount - Global.temp_def, 1)
	if Main.kr:
		Global.player_kr += area.kr
	if Global.player_kr >= Global.player_hp:
		Global.player_kr = max(Global.player_hp -1, 0)
	if Global.player_hp <= 0 and !Global.debugmode:
		Global.player_position = get_global_transform_with_canvas().origin
		get_tree().change_scene_to_file("res://Battle/Death/death_screen.tscn")
		return
	HurtSound.play()


func heal(area: BulletArea) -> void:
	hiframes = 1
	Global.heal(area.damage)
	Global.player_kr += min(area.kr, area.damage) + 1
	if Global.player_kr >= Global.player_hp:
		Global.player_kr = max(Global.player_hp -1, 0)
	Global.heal_sound.play()

#func match_sprites_with_soul():
	#pass var texture: Texture2D = sprites.sprite_frames.get_frame_texture(sprites.get_animation(), sprites.frame)
	#ghost.texture = texture

func set_mode(new_mode := RED) -> void:
	set_mode_silent(new_mode)
	ModeChangeS.play()
	ghost.restart()
	ghost.emitting = true
	#match_sprites_with_soul()

var fade_tw: Tween
const FADE_TIME: float = 0.2

func set_mode_silent(new_mode := RED) -> void:
	mode = new_mode
	if not is_node_ready():
		return
	
	for key in ModeNodes:
		assert(ModeNodes[key] is Node, "PLEASE Put a Node as a value in \"ModeNodes\"")
		if key != new_mode:
			if ModeNodes[key].is_inside_tree():
				fade_tw = create_tween()
				fade_tw.tween_property(ModeNodes[key], "modulate:a", 0, FADE_TIME)
				fade_tw.tween_callback(remove_child.bind(ModeNodes[key]))
		elif !ModeNodes[key].is_inside_tree():
			fade_tw = create_tween()
			ModeNodes[key].modulate.a = 0
			fade_tw.tween_property(ModeNodes[key], "modulate:a", 1, FADE_TIME)
			add_child(ModeNodes[key])
	
	if new_mode == PURPLE:
		purple_pos = 0
		update_purple_pos()
		
	
	if new_mode != BLUE:
		set_gravity_direction_silent(Vector2.DOWN)
	
func set_gravity_direction(new_direction: Vector2, force_blue_mode: bool = true) -> void:
	velocity = Vector2.ZERO
	gravity_direction = new_direction
	up_direction = gravity_direction * -1
	if force_blue_mode:
		set_mode(BLUE)
	rotation = Vector2.RIGHT.angle_to(new_direction) - PI / 2.0

func set_gravity_direction_silent(new_direction: Vector2) -> void:
	gravity_direction = new_direction
	up_direction = gravity_direction * -1
	rotation = Vector2.RIGHT.angle_to(new_direction) - PI / 2.0

const DIRS = {
	Vector2.DOWN: 0,
	Vector2.LEFT: 1,
	Vector2.UP: 2,
	Vector2.RIGHT: 3,
}


func red() -> void:
	sprites.modulate = Color(1, 1, 1, 1) if soul_type == soul_types.SOUL_MONSTER else Color(1, 0, 0 , 1)
	four_dir_movement()


func four_dir_movement() -> void:
	slow_down = int(Input.is_action_pressed("ui_cancel")) + 1
	inputlist = Vector2(
		Input.get_action_raw_strength("ui_right") - Input.get_action_raw_strength("ui_left"),
		Input.get_action_raw_strength("ui_down") - Input.get_action_raw_strength("ui_up")
		)
	motion = speed * inputlist / slow_down

var motion := Vector2.ZERO

func blue() -> void:
	sprites.modulate = Color(0, 0, 1, 1)
	slow_down = int(Input.is_action_pressed("ui_cancel")) + 1
	match gravity_direction:
		Vector2.DOWN:
			inputlist = Vector2(
				Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
				Input.is_action_pressed("ui_up"))
		Vector2.LEFT:
			inputlist = Vector2(
				Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up"),
				Input.is_action_pressed("ui_right"))
		Vector2.RIGHT:
			inputlist = Vector2(
				Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up"),
				Input.is_action_pressed("ui_left"))
		Vector2.UP:
			inputlist = Vector2(
				Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
				Input.is_action_pressed("ui_down"))
	if not is_on_floor():
		motion.y += gravity * gravity_multiplier
	motion.x = speed * ceil(inputlist.x) / slow_down
	if is_on_floor():
		if motion.y > 0: motion.y = 0
		if gravity_multiplier > 1.0:
			gravity_multiplier = 1.0
			$Wallhit.play()
			shake_camera.emit(0.6)
		if inputlist.y:
			motion.y -= jump[3]
	else:
		if motion.y > 0:
			motion.y += gravity * (jump[2]-1.0)
		elif not inputlist.y:
			if motion.y < 20:
				motion.y = lerpf(motion.y, 0, (jump[1]-1.0) / 20.0)
			else:
				motion.y = lerpf(motion.y, 20, (jump[0]-1.0) / 20.0)

func _motion_align_gravity_direction() -> void:
	if gravity_direction.x:
		velocity.x = motion.y * gravity_direction.x
		velocity.y = motion.x
	else:
		velocity.y = motion.y * gravity_direction.y
		velocity.x = motion.x
	
	move_and_slide()

func green() -> void:
	motion = Vector2.ZERO
	sprites.modulate = Color.WEB_GREEN
	pass

func yellow() -> void:
	sprites.modulate = Color.YELLOW
	sprites.scale.y = -1
	if Input.is_action_just_pressed("ui_accept"):
		Shoot.play()
		var _c = yellow_bullet.instantiate() as YellowBullet
		Main.Box.add_child(_c)
		_c.global_position = sprites.global_position
		_c.rotation = sprites.global_rotation
		_c.velocity = Vector2.UP.rotated(sprites.global_rotation) * YellowBullet.SPEED
	four_dir_movement()

var purple_pos: int = 0
var p_tween: Tween

func purple() -> void:
	sprites.modulate = Color.PURPLE
	slow_down = int(Input.is_action_pressed("ui_cancel")) + 1
	inputlist = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	motion.x = speed * inputlist.x / slow_down
	if Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("ui_up"):
		purple_pos += int(round(inputlist.y))
		purple_pos = clamp(purple_pos, 0 , Main.Box.WebsArray.size() - 1)
		update_purple_pos()


func update_purple_pos():
	if purple_pos < -1:
		purple_pos = 0
		return
	if p_tween and p_tween.is_valid(): p_tween.kill()
	p_tween = create_tween()
	p_tween.tween_property(self, "global_position:y", Main.Box.get_web_y_pos(purple_pos), 0.1)
	await p_tween.finished

func orange() -> void:
	sprites.modulate = Color(1, 0.65, 0)
	motion = speed * inputlist

func _unhandled_input(event: InputEvent) -> void:
	if mode == ORANGE:
		var _input_list_pressed =  Vector2(
			int(event.is_action_pressed("ui_right")) - int(event.is_action_pressed("ui_left")),
			int(event.is_action_pressed("ui_down")) - int(event.is_action_pressed("ui_up"))
		)
		if _input_list_pressed.x: inputlist.x = _input_list_pressed.x
		if _input_list_pressed.y: inputlist.y = _input_list_pressed.y 

func cyan() -> void:
	sprites.modulate = Color.CYAN
	slow_down = int(Input.is_action_pressed("ui_cancel")) + 1
	inputlist = Vector2(
		Input.get_action_raw_strength("ui_right") - Input.get_action_raw_strength("ui_left"),
		Input.get_action_raw_strength("ui_down") - Input.get_action_raw_strength("ui_up")
		)
	motion = speed * inputlist / slow_down if CyanDetector.can_move else Vector2.ZERO
