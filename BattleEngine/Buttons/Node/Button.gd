extends Node2D
class_name Buttons

@onready var Box = get_node("/root/main/box")
@onready var soul = $MenuSoul
@onready var squ = $Squeak
@onready var sel = $Select
var selected = 0
var input
var positions =[0, 153, 312, 465]
var enabled = true

signal select(choice)
signal finishintro
# Called when the node enters the scene tree for the first time.
func _ready():
	if get_node("/root/main/soul")&&get_node("/root/main/soul").soultype == "monster":
		soul.scale.y = -1
		soul.modulate = Color.WHITE
	else:
		soul.scale.y = 1
		soul.modulate = Color.RED
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if enabled:
		if Input.is_action_just_pressed("Confirm"):
			choose()
			sel.play()
		if Input.is_action_just_pressed("ui_right"):
			squ.play()
			if selected > 2:
				selected = 0
			else: 
				selected += 1
		if Input.is_action_just_pressed("ui_left"):
			squ.play()
			if selected < 1:
				selected = 3
			else:
				selected -=1
	movesoul(selected)
func movesoul(pos): #0,1,2,3
	if enabled:
		soul.position = Vector2(positions[pos]-38,0)
		for i in range(0,4,1):
			self.get_child(i).frame = 0
		self.get_child(pos).frame = 1

func disable():
	enabled = false
	for i in range(0,4,1):
		self.get_child(i).frame = 0
	soul.visible = false
	pass
	
func enable():
	enabled = true
	soul.visible = true
	pass

func choose():
	disable()
	emit_signal("select",selected)

