extends RayCast2D

var teleportdistance = 100.0
var possibletpvec = Vector2.ZERO
@onready var Camera:Camera2DVFX
@onready var preview = $TeleportThing

@export var tprange = 70.0
@export var horizontaltp = true
@export var verticaltp = false

signal teleported
# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().process_frame
	Camera = get_node("/root/main/Camera2D")
	Game.tpready.connect(func():
		$ready.play()
	)
	pass # Replace with function body.

func _input(event):
	if event.is_action_pressed("ui_down")&&verticaltp:
		target_position= Vector2(0,10000)
	elif event.is_action_pressed("ui_up")&&verticaltp:
		target_position= Vector2(0,-10000)
	elif event.is_action_pressed("ui_left")&&horizontaltp:
		target_position= Vector2(-10000,0)
	elif event.is_action_pressed("ui_right")&&horizontaltp:
		target_position= Vector2(10000,0)
	if event.is_action_pressed("Confirm")&&cantp():
		teleport()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	possibletpvec = get_collision_point() - get_parent().global_position
	if cantp():
		self.visible = true
	else:
		self.visible = false
	
func refreshtpsprite(sprite,color):
	preview.modulate = color
	preview.texture = sprite
	preview.position = returntpvector()
	if sprite==load(get_parent().soul_split):
		self.hide()
	
func cantp():
	return get_parent().visible and get_parent().mode != "cutscene" and Game.tpcd >= 1.0 and get_parent().hp >0
func teleport():
	get_parent().iframes = Game.hurtframe
	Game.tpcd -= 1
	Camera.blinder.modulate.a = 1
	$noise.play()
	get_parent().position += returntpvector()
	await get_tree().create_timer(0.08).timeout
	$noise.play()
	Camera.blinder.modulate.a = 0
	emit_signal("teleported")
	

func returntpvector():
	var tpdir = sign(target_position)
	var tpvector = Vector2(min(abs(possibletpvec.x)-7,tprange)*tpdir.x,min(abs(possibletpvec.y)-7,tprange)*tpdir.y)
	return tpvector
