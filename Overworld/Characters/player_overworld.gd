@icon("res://Overworld/Characters/player_icon.png")
extends CharacterBody2D
class_name PlayerOverworld

var walk_anims = [[0,1,2,3],[8,9,10,11],[16,17,16,17]]
var shadow := false
var current_animation = walk_anims[0]
var frame_counter = -1

@export_range(0,500) var walk_speed : float = 80.0
var walk_speed_modifier := 1.0

var inputs :Array[float] = []
@onready var Sprite = $Sprite
@onready var Interacter = $Interacter/Collision
@onready var InteracterArea = $Interacter

@export var InteractPosx = {
	1 : Vector2.ZERO,
	-1 : Vector2.ZERO,
}
@export var InteractPosy = {
	1 : Vector2.ZERO,
	-1 : Vector2.ZERO,
}
enum directions{
	DOWN,
	UP,
	LEFT,
	RIGHT,
}
var direction := Vector2.ZERO

var interactables = []

var playermenu = preload("res://Overworld/ui.tscn")
func _physics_process(delta):
	if Global.player_can_move and !Global.player_in_menu:
		setdirection()
		velocity.x = direction.x * walk_speed * walk_speed_modifier
		velocity.y = direction.y * walk_speed * walk_speed_modifier
		move_and_slide()
		Global.player_position = get_global_transform_with_canvas().origin + Vector2(0,-15)
	interactables.clear()
	for area in InteracterArea.get_overlapping_areas():
		if area.is_in_group("interactable"):
			interactables.append(area)

func setdirection():
		inputs = [
			Input.is_action_pressed("ui_down"),
			Input.is_action_pressed("ui_up"),
			Input.is_action_pressed("ui_left"),
			Input.is_action_pressed("ui_right")
		]
		direction = Vector2(inputs[3] - inputs[2],inputs[0] - inputs[1])
		Interacter.position = InteractPosx.get(int(direction.x),Interacter.position)
		Interacter.position = InteractPosy.get(int(direction.y),Interacter.position)
		if direction.x : Interacter.rotation_degrees = 90.0
		if direction.y: Interacter.rotation_degrees = 0.0
		if direction and !moving:
			moving = true
			$Timer.stop()
			$Timer.start()
			_on_timer_timeout()
			if direction:
				match direction.x:
					1.0:
						current_animation = walk_anims[2]
						Sprite.flip_h = true
					-1.0:
						current_animation = walk_anims[2]
						Sprite.flip_h = false
				match direction.y:
					1.0:
						current_animation = walk_anims[0]
						Sprite.flip_h = false
					-1.0:
						current_animation = walk_anims[1]
						Sprite.flip_h = false
				Sprite.frame = current_animation[0] + int(shadow) * 4

var moving := false

func _ready():
	moving = false
	setdirection()
	if direction:
		match direction.x:
			1.0:
				current_animation = walk_anims[2]
				Sprite.flip_h = true
			-1.0:
				current_animation = walk_anims[2]
				Sprite.flip_h = false
		match direction.y:
			1.0:
				current_animation = walk_anims[0]
				Sprite.flip_h = false
			-1.0:
				current_animation = walk_anims[1]
				Sprite.flip_h = false
		Sprite.frame = current_animation[0] + int(shadow) * 4
		moving = true

func _unhandled_input(event):
	if Global.player_can_move and !Global.player_in_menu:
		if (event.is_action("ui_down") 
		or event.is_action("ui_up") 
		or event.is_action("ui_left") 
		or event.is_action("ui_right")
		) and (event.is_pressed() or event.is_released()):
			setdirection()
			if direction:
				match direction.x:
					1.0:
						current_animation = walk_anims[2]
						Sprite.flip_h = true
					-1.0:
						current_animation = walk_anims[2]
						Sprite.flip_h = false
				match direction.y:
					1.0:
						current_animation = walk_anims[0]
						Sprite.flip_h = false
					-1.0:
						current_animation = walk_anims[1]
						Sprite.flip_h = false
				Sprite.frame = current_animation[frame_counter % 4] + int(shadow) * 4
			elif moving and event.is_released() and !direction:
				moving = false
				if Sprite.frame % 2 == 1 :
					Sprite.frame = current_animation[0] + int(shadow) * 4
		if event.is_action_pressed("ui_accept"):
			get_viewport().set_input_as_handled()
			for i in interactables:
				i.interacted.emit()
		if event.is_action_pressed("ui_menu"):
			var menu = playermenu.instantiate()
			add_child(menu)
	else:
		moving = false
		Sprite.frame = current_animation[0] + int(shadow) * 4

func _on_timer_timeout():
	if Global.player_can_move and !Global.player_in_menu and moving:
		anim_step()
	else:
		if Sprite.frame % 2 == 1:
			Sprite.frame = current_animation[0] + int(shadow) * 4

func anim_step():
	frame_counter += 1
	Sprite.frame = current_animation[frame_counter % 4] + int(shadow) * 4
