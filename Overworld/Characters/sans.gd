extends CharacterBody2D

@export var dialogues: Array[Dialogues] = []
@export_multiline var speech_text: PackedStringArray = ["Heya kid", "Amongus"]
@export var speech_heads := [0, 1]
var text_box := preload("res://Overworld/text_box.tscn")

var walk_anims := [[0, 1, 2, 3], [12, 13, 14, 15], [4, 5, 6, 7], [8, 9, 10, 11]]
var current_animation: Array = walk_anims[0]

var walk_direction := Vector2i.ZERO

var canmove := true
var counter := 0
@export_range(0, 400) var walk_speed: int = 60
var walk_speed_mod: float = 1.0

@onready var Sprite: AnimatedSprite2D = $Sprite
@onready var WalkCycleTimer: Timer = $Timer

func start_walking(direction: Vector2i = Vector2i.ZERO) -> void:
	canmove = true
	set_walk_direction(direction)

func set_walk_direction(direction: Vector2i) -> void:
	walk_direction = direction
	match walk_direction.x:
		1:
			current_animation = walk_anims[3]
		-1:
			current_animation = walk_anims[2]
	match walk_direction.y:
		1:
			current_animation = walk_anims[0]
		-1:
			current_animation = walk_anims[1]
	Sprite.frame = current_animation[counter % 4]

func _physics_process(delta: float) -> void:
	velocity = walk_direction * walk_speed * walk_speed_mod
	if canmove:
		move_and_collide(velocity * delta)


func _on_timer_timeout() -> void:
	if velocity and canmove:
		counter += 1
		Sprite.frame = current_animation[counter % 4]
	else:
		Sprite.frame = current_animation[0]

func _on_area_interacted() -> void:
	var ct: TextBox = text_box.instantiate()
	add_child(ct)
	ct.character(TextBox.SANS, dialogues[0].get_dialogues_single(Dialogues.DIALOGUE_TEXT), dialogues[0].get_dialogues_single(Dialogues.DIALOGUE_EXPRESSION_HEAD))
