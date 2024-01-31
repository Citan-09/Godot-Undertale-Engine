@icon("res://Battle/Soul/soul.png")
extends CharacterBody2D
class_name SoulBattle

var gravity_multiplier: float = 1
var jump := [8.0, 5.0, 2.5, 170.0]
var stop_speed = 26
var speed = 190
var gravity = 3.25

@export var soul_type = soul_types.SOUL_HUMAN
var mode = RED
var inputlist := Vector2.ZERO
var slow_down: int

var gravity_direction := Vector2.DOWN
@export_enum("ARROW_KEYS", "VELOCITY", "ARROW_KEYS_AND_MOVING") var special_bullet_mode = 0
@onready var sprites = $Sprite
@onready var ghost = $Sprite/Ghost
@onready var mode_change = $Ding
@onready var Main = $/root/main
@onready var hurtsound = $Hurt
@onready var Area = $Area2D

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

var hiframes = 0.0
var iframes = 0.0
var invulnerable = false
var overlapping_areas = []

signal shake_camera(amt: float)
func _ready() -> void:
	set_gravity_direction(Vector2.DOWN, false)
	modulate.a = 0
	set_physics_process(false)
	set_process(false)
	

func disable():
	if is_processing():
		set_process(false)
		set_physics_process(false)
		var tw = create_tween().tween_property(self, "modulate:a", 0, 0.5)
		await tw.finished
		get_parent().remove_child.call_deferred(self)

func _enter_tree() -> void:
	enable()
	motion = Vector2.ZERO
	velocity = Vector2.ZERO
	gravity_direction = Vector2.DOWN
	mode = DISABLE_MOVEMENT

func enable() -> void:
	if !is_processing():
		if !is_node_ready(): await ready
		position = Vector2(320, 320)
		var tw = create_tween()
		tw.tween_property(self, "modulate:a", 1, 0.5)
		await tw.finished
		tw.kill()
		set_process(true)
		set_physics_process(true)

func _physics_process(delta: float) -> void:
	if gravity_direction.x:
		motion.x = velocity.y
		motion.y = velocity.x * gravity_direction.x
	else:
		motion.y = velocity.y * gravity_direction.y
		motion.x = velocity.x
	
	up_direction = gravity_direction * -1
	match mode:
		RED:
			red(delta)
		BLUE:
			blue(delta)
		DISABLE_MOVEMENT:
			sprites.modulate = Color(1, 1, 1, 1) if soul_type == soul_types.SOUL_MONSTER else Color(1, 0, 0 , 1)
	_motion_align_gravity_direction()
	
	overlapping_areas = Area.get_overlapping_areas()
	for i in overlapping_areas.size():
		check_bullet(overlapping_areas[i])


func _process(delta: float) -> void:
	var delta_frame = ProjectSettings.get_setting("max_fps", Engine.get_frames_per_second())
	iframes -= delta * delta_frame
	hiframes -= delta * delta_frame
	if iframes > 0:
		if int(iframes) % 8 == 0:
			self.modulate.a = 1
		elif int(iframes) % 8 == 4 and Global.settings["vfx"]:
			self.modulate.a = 0.6
	else:
		self.modulate.a = 1


func check_bullet(area):
	if !invulnerable and area.is_in_group("bullet"):
		if hiframes <= 0:
			match area.damage_mode:
				bullet.damage_modes.GREEN:
					heal(area)
		if iframes <= 0:
			match area.damage_mode:
				bullet.damage_modes.WHITE:
					hurt(area)
				bullet.damage_modes.BLUE:
					if special_bullet_mode == 0 and !inputlist.is_zero_approx() or special_bullet_mode == 1 and velocity or special_bullet_mode == 2 and (!inputlist.is_zero_approx() and velocity):
						hurt(area)
				bullet.damage_modes.ORANGE:
					if special_bullet_mode == 0 and !inputlist.is_zero_approx() or special_bullet_mode == 1 and not velocity or special_bullet_mode == 2 and not (!inputlist.is_zero_approx() and velocity):
						hurt(area)

func hurt(area):
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
	hurtsound.play()


func heal(area):
	hiframes = 1
	Global.heal(area.damage)
	Global.player_kr += min(area.kr, area.damage) + 1
	if Global.player_kr >= Global.player_hp:
		Global.player_kr = max(Global.player_hp -1, 0)
	Global.heal_sound.play()

func match_sprites_with_soul():
	var texture: Texture2D = sprites.sprite_frames.get_frame_texture(sprites.get_animation(), sprites.frame)
	ghost.texture = texture

func set_mode(new_mode := RED):
	mode_change.play()
	ghost.restart()
	ghost.emitting = true
	mode = new_mode
	if new_mode != BLUE:
		gravity_direction = Vector2.DOWN
	match_sprites_with_soul()


func set_gravity_direction(new_direction: Vector2, force_blue_mode: bool = true):
	velocity = Vector2.ZERO
	gravity_direction = new_direction
	if force_blue_mode:
		mode_change.play()
		mode = BLUE
		ghost.restart()
		ghost.emitting = true
	sprites.frame = DIRS[new_direction]
	sprites.animation = &"directions" if soul_type == soul_types.SOUL_HUMAN else &"directions_m"
	match_sprites_with_soul()

const DIRS = {
	Vector2.DOWN: 0,
	Vector2.LEFT: 1,
	Vector2.UP: 2,
	Vector2.RIGHT: 3,
}

func red(delta):
	sprites.modulate = Color(1, 1, 1, 1) if soul_type == soul_types.SOUL_MONSTER else Color(1, 0, 0 , 1)
	slow_down = int(Input.is_action_pressed("ui_cancel")) + 1
	inputlist = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	motion = speed * inputlist / slow_down

var motion := Vector2.ZERO

func blue(delta):
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

func _motion_align_gravity_direction():
	if gravity_direction.x:
		velocity.x = motion.y * gravity_direction.x
		velocity.y = motion.x
	else:
		velocity.y = motion.y * gravity_direction.y
		velocity.x = motion.x
	
	move_and_slide()



