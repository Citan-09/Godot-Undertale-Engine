@icon("res://Overworld/Characters/player_icon.png")
extends CharacterBody2D
class_name PlayerOverworld

var walk_anims: Array = [[0, 1, 2, 3], [8, 9, 10, 11], [16, 17, 16, 17]]
var shadow := false
var current_animation: Array = walk_anims[0]
var frame_counter: int = -1

@export_range(0, 500) var walk_speed: float = 80.0
var walk_speed_modifier := 1.0

@export var Encounters: Array[Encounter] =[
	
]
@export var StepCounterNeeded: int = 75
var step_count: int = 0

@onready var Sprite: AnimatedSprite2D = $Sprite
@onready var Interacter: Area2D = $Interacter

@export var InteractPosx := {
	1: Vector2.ZERO,
	-1: Vector2.ZERO,
}
@export var InteractPosy := {
	1: Vector2.ZERO,
	-1: Vector2.ZERO,
}
enum directions {
	DOWN,
	UP,
	LEFT,
	RIGHT,
}

var last_dir: Vector2
var direction := Vector2.ZERO

var interactables := []

var playermenu: PackedScene = preload("res://Overworld/ui.tscn")

func _physics_process(_delta: float) -> void:
	if Global.player_can_move and !Global.player_in_menu:
		var moving_old = moving
		refresh_direction()
		if moving > moving_old:
			frame_counter = 1
		velocity.x = direction.x * walk_speed * walk_speed_modifier
		velocity.y = direction.y * walk_speed * walk_speed_modifier
		move_and_slide()
		Global.player_position = get_global_transform_with_canvas().origin + Vector2(0, -17)
	Sprite.frame = current_animation[frame_counter % 4 if moving else 0] + int(shadow) * 4
	interactables.clear()
	for area in Interacter.get_overlapping_areas():
		if area.is_in_group("interactable"):
			interactables.append(area)


func refresh_direction() -> void:
	direction = Vector2(
		Input.get_action_raw_strength("ui_right") - Input.get_action_raw_strength("ui_left"),
		Input.get_action_raw_strength("ui_down") - Input.get_action_raw_strength("ui_up")
		)
	set_direction()

func force_direction(dir: Vector2) -> void:
	direction = dir.normalized()
	set_direction()

func set_direction() -> void:
	Interacter.position = InteractPosx.get(int(direction.x), Interacter.position)
	Interacter.position = InteractPosy.get(int(direction.y), Interacter.position)
	if direction.x: Interacter.rotation_degrees = 90.0
	if direction.y: Interacter.rotation_degrees = 0.0
	if direction and !moving:
		moving = true
		$Timer.stop()
		$Timer.start()
	if direction: last_dir = direction
	match last_dir.x:
		1.0:
			current_animation = walk_anims[2]
			Sprite.flip_h = true
		-1.0:
			current_animation = walk_anims[2]
			Sprite.flip_h = false
	match last_dir.y:
		1.0:
			current_animation = walk_anims[0]
			Sprite.flip_h = false
		-1.0:
			current_animation = walk_anims[1]
			Sprite.flip_h = false
	if !direction or !Global.player_can_move or Global.player_in_menu:
		moving = false


var moving := false

func _unhandled_input(event: InputEvent) -> void:
	if Global.player_can_move and !Global.player_in_menu:
		if (	   event.is_action_pressed("ui_left")
				or event.is_action_pressed("ui_right")
				or event.is_action_pressed("ui_up")
				or event.is_action_pressed("ui_down")
			):
				_step()
		if event.is_action_pressed("ui_accept"):
			get_viewport().set_input_as_handled()
			for i: InteractionTrigger in interactables:
				i.interacted.emit()
		if event.is_action_pressed("ui_menu"):
			var menu: Node = playermenu.instantiate()
			add_child(menu)
	else:
		moving = false

func _on_timer_timeout() -> void:
	if moving:
		frame_counter += 1
		_step()

func _step() -> void:
	step_count += 1
	if step_count > StepCounterNeeded and randf() > 0.11:
		step_count = 0
		_enter_random_encounter()
	

func _enter_random_encounter() -> void:
	Global.player_can_move = false
	if Encounters.is_empty():
		return
	$Alert.show()
	$encounter.play()
	await get_tree().create_timer(0.35, false).timeout
	OverworldSceneChanger.load_battle(OverworldSceneChanger.DEFAULT_BATTLE, Encounters.pick_random(), true)
	await get_tree().create_timer(0.6, false).timeout
	$Alert.hide()
