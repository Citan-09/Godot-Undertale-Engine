extends CharacterBody2D

signal done
@export var speed = 80.0
var canmove = true
var moving:float = 0
@onready var clock:Timer = $Timer
@onready var sprite = $Sprite
	
func _process(delta: float) -> void:
	moving = Input.is_action_pressed("ui_down")
	self.position.y += moving*speed*delta*int(canmove)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down")&&canmove:
		if counter % 2 ==0:
			counter += 1
		sprite.frame = counter % 4
		counter += 1
		clock.stop()
		clock.start(0.0)
var animation = [0,1,2,3]
var counter = 0

func _on_timer_timeout() -> void:
	if moving&&canmove:
		sprite.frame = counter % 4
	elif sprite.frame %2 ==1:
		sprite.frame = 0
	counter+=1
