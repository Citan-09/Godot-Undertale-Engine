extends Node2D

var enabled = false

@onready var move = $choice
@onready var select = $select
@onready var buttons = [$Button1,$Button2,$Button3,$Button4]
var choice := 0
signal movesoul(newpos:Vector2)
signal selectbutton(id:int)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left") and enabled:
		changepos(-1)
	if event.is_action_pressed("ui_right") and enabled:
		changepos(1)
	if event.is_action_pressed("ui_accept") and enabled:
		disable()
		get_viewport().set_input_as_handled()
		emit_signal("selectbutton",choice)
		select.play()

func changepos(action:int):
	move.play()
	choice = posmod(choice + action,4)
	emit_signal("movesoul",buttons[choice].global_position - Vector2(38,0))
	glow_choice(choice)
	
func glow_choice(id : int):
	for i in buttons:
		i.frame = 0
	buttons[id].frame = 1
	
func enable():
	enabled = true
	changepos(0)

func disable():
	enabled = false
	
func reset():
	for i in buttons:
		i.frame = 0
