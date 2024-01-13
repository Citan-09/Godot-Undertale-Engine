extends CharacterBody2D

const SPEED = 110.0
const JUMP_VELOCITY = -400.0

@export var reach = 12
@onready var Interactbox = $InteractBox
@onready var Sprite = $AnimatedSprite2D
@onready var col = $CollisionShape2D

var walkh = [16,17,16,17]
var walkdown = [0,1,2,3]
var walkup = [8,9,10,11]
var inshadow = false
var counter = 0
@export var FPS = 5.0

var dir:Vector2
var currentanim = walkh

func ismoving():
	if Global.canmove:
		return Input.is_action_pressed("ui_up")or Input.is_action_pressed("ui_down") or Input.is_action_pressed("ui_left")or Input.is_action_pressed("ui_right")
func togglemove(to):
	Global.canmove = to
func _physics_process(delta):
	if Global.canmove:
		dir = Vector2(Input.get_axis("ui_left", "ui_right"),Input.get_axis("ui_up", "ui_down"))
		if dir.x >0:
			Sprite.flip_h = true
		elif dir.x <0:
			Sprite.flip_h = false
		if dir.y!=0:
			Sprite.flip_h = false
		setanimdir()
		if dir.x:
			velocity.x = dir.x * SPEED
			Interactbox.position =Vector2(reach*dir.x,0)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		if dir.y:
			velocity.y = dir.y * SPEED
			Interactbox.position =Vector2(0,reach/2.0*dir.y)
		else:
			velocity.y = move_toward(velocity.y, 0, SPEED)
		#direction
		#if Input.is_action_just_released("ui_up")or Input.is_action_just_released("ui_down") or Input.is_action_just_released("ui_left")or Input.is_action_just_released("ui_right"):
		#	if Global.canmove:
		#		dir = directiony
		#		if dir == 0:
		#			dir = direction +3
		move_and_slide()
func _unhandled_input(event: InputEvent) -> void:
	onpresssetanimdir(event)
	if event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down") or event.is_action_pressed("ui_right") or event.is_action_pressed("ui_left"):
		if Global.canmove:
			dir = Vector2(Input.get_axis("ui_left", "ui_right"),Input.get_axis("ui_up", "ui_down"))
			setanimdir()
			if counter % 2 == 0:
				counter += 1
			Sprite.frame = currentanim[counter%4]
			$Timer.stop()
			$Timer.start(0.0)
		else:
			self.velocity = Vector2.ZERO
			dir = Vector2.ZERO
		

func _ready() -> void:
	$Timer.wait_time = 1.0/FPS

func _on_timer_timeout() -> void:
	counter += 1
	if (dir == Vector2(0,0) or !Global.canmove) and Sprite.frame % 2 == 1:
		Sprite.frame = currentanim[0]
	
func onpresssetanimdir(input):
	if input.is_action_pressed("ui_right"):
		currentanim = walkh
	if input.is_action_pressed("ui_left"):
		currentanim = walkh
	if input.is_action_pressed("ui_up"):
		currentanim = walkup
	if input.is_action_pressed("ui_down"):
		currentanim = walkdown

func setanimdir():
	if dir.x !=0:
		currentanim = walkh
	if dir.y >0:
		currentanim = walkdown
	if dir.y <0:
		currentanim = walkup
	if dir != Vector2(0,0) and Global.canmove:
		Sprite.frame = currentanim[counter%4]


