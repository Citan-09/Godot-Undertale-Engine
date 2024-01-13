extends CharacterBody2D
class_name PlayerSoul

@onready var Sprite = $Soul
@onready var modeS = $Mode
@onready var hurtS = $Hurt
@onready var healfx = $Heal
@onready var modeS1 = $changemode

@onready var Butn = get_node("/root/main/Camera2D/buttons")
@onready var Camera = get_node("/root/main/Camera2D")
@onready var gui = get_node("/root/main/Camera2D/gui")
var soul = "res://Shared/Soul/soul.png"
var soul_l = "res://Shared/Soul/soul_l.png"
var soul_u = "res://Shared/Soul/soul_u.png"
var soul_r = "res://Shared/Soul/soul_r.png"
var soul_split = "res://Shared/Soul/crack.png"
var current

var color
var canstop = true
var direction:float
var directiony:float
var mode = "cutscene"
var slowfactor = 1.0
@export var soultype = "human"
var redsoul = Color.RED

const SPEED = 160.0
const JUMP_VELOCITY = 220.0
const JUMP_STOP = 20.0
const slow2 = 6


var gdir = "down"

signal glow
signal predeath

var hp = 20
var maxhp = 20
var kr = 0
var healing = false
var inbullet = false
var bulletdamtemp = 0
var canhurt = true

var slammult = 1
var iframes:float

var counter = 0.0
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	await get_tree().process_frame
	if soultype == "monster":
		redsoul = Color.WHITE
	clockkr()
	maxhp = hp
	changedir("down")
	var krclock = get_tree().create_tween().set_loops().bind_node(self)
	krclock.tween_callback(clockkr).set_delay(0.75)

func clockkr():
	if kr >0:
		kr -= 1
		hp -= 1
	gui.refresh()
func _physics_process(delta):
	for i in $Area2D.get_overlapping_areas():
		if i.is_in_group("bullet"):
			matchcolor(i)
	if Game.krbool && kr > hp - 1:
			kr = hp -1
	match mode:
		"blue":
			blue(delta)
			Sprite.modulate = Color.BLUE
		"red":
			red(delta)
			Sprite.modulate = redsoul
	move_and_slide()

func _extraprocess(delta):
	pass

func _process(delta):
	counter += 0.2
	iframes -= delta*60
	if iframes <= 0:
		canhurt = true
		canheal = true
	else:
		canhurt = false
	if Global.debug:
		canhurt = false
		Sprite.self_modulate = Color(2,2,2,1)
	elif !canhurt:
		if int(counter) % 2 ==0:
			Sprite.modulate.a = 0.75
		elif Data.settings["vfxmult"]:
			Sprite.modulate.a = 1
	
	
	if Input.is_action_pressed("slow_down"):
		slowfactor = 0.5
	else:
		slowfactor = 1
	_extraprocess(delta)
func setmode(m: String):
	if m != "blue":
		changedir("down")
		changetextures()
	mode = m
	modeS1.play()
	$Soul/trail2.restart()
	$Soul/trail2.emitting = true
	
func changetextures():
	$Soul.texture = current
	$Soul/trail.texture = current
	$Soul/trail2.texture = current
func changedir(dir,playsound = true):
	if soultype == "human":
		match dir:
			"down":
				current = load(soul)
				up_direction = Vector2.UP
			"up":
				current = load(soul_u)
				up_direction = Vector2.DOWN
			"left":
				current = load(soul_l)
				up_direction = Vector2.RIGHT
			"right":
				current = load(soul_r)
				up_direction = Vector2.LEFT
	elif soultype == "monster":
		match dir:
			"down":
				current = load(soul_u)
				up_direction = Vector2.UP
			"up":
				current = load(soul)
				up_direction = Vector2.DOWN
			"left":
				current = load(soul_r)
				up_direction = Vector2.RIGHT
			"right":
				current = load(soul_l)
				up_direction = Vector2.LEFT
	if playsound:
		pass
		#modeS1.play()
	changetextures()
	gdir = dir
func throw(dir):
	canstop = false
	changedir(dir,false)
	mode = "blue"
	$Soul/trail.restart()
	$Soul/trail2.emitting = true
	slammult = 15
	
	await get_tree().create_timer(0.1).timeout
	canstop = true
func ifpresskey():
	if mode == "red":
		return(Input.get_axis("ui_left","ui_right") != 0 or Input.get_axis("ui_down","ui_up") != 0)
	if mode == "blue":
		match gdir:
			"down":
				return(Input.get_axis("ui_left","ui_right") != 0 or Input.is_action_pressed("ui_up"))
			"up":
				return(Input.get_axis("ui_left","ui_right") != 0 or Input.is_action_pressed("ui_down"))
			"left":
				return(Input.get_axis("ui_down","ui_up") != 0 or Input.is_action_pressed("ui_right"))
			"right":
				return(Input.get_axis("ui_down","ui_up") != 0 or Input.is_action_pressed("ui_left"))
func ifjumpkey():
	var string = "ui_"
	string += returnjumpdir()
	return Input.is_action_pressed(string)
func returnjumpdir():
	match gdir:
		"down":
			return "up"
		"up":
			return "down"
		"left":
			return "right"
		"right":
			return "left"

func blue(delta):
	match gdir:
		"down":
			if not is_on_floor():
				velocity.y += gravity * delta * slammult
		"up":
			if not is_on_floor():
				velocity.y -= gravity * delta * slammult
		"left":
			if not is_on_floor():
				velocity.x -= gravity * delta * slammult
		"right":
			if not is_on_floor():
				velocity.x += gravity * delta * slammult
	if is_on_floor()&&slammult != 1 && canstop:
		$Impact.play()
		slammult = 1
		Camera.addshake(0.5)
	
	if gdir == "down":
		if ifjumpkey() && self.velocity.y == 0 && is_on_floor():
			self.velocity.y -= JUMP_VELOCITY
		if !ifjumpkey() && self.velocity.y < -JUMP_STOP:
			self.velocity.y += JUMP_STOP * slammult
	elif gdir == "up":
		if ifjumpkey() && self.velocity.y == 0 && is_on_floor():
			self.velocity.y += JUMP_VELOCITY
		if !ifjumpkey() && self.velocity.y > JUMP_STOP:
			self.velocity.y -= JUMP_STOP * slammult
	
	if gdir == "down" or gdir == "up":
		direction = Input.get_axis("ui_left", "ui_right")
		if direction:
			self.velocity.x = direction * SPEED * slowfactor
		else:
			self.velocity.x = stop(self.velocity.x)
	if gdir == "left":
		if ifjumpkey() && self.velocity.x == 0 && is_on_floor():
			self.velocity.x += JUMP_VELOCITY
		elif !ifjumpkey() && self.velocity.x > JUMP_STOP:
			self.velocity.x -= JUMP_STOP * slammult
	elif gdir == "right":
		if ifjumpkey() && self.velocity.x == 0 && is_on_floor():
			self.velocity.x -= JUMP_VELOCITY
		elif !ifjumpkey() && self.velocity.x < -JUMP_STOP:
			self.velocity.x += JUMP_STOP * slammult
	if gdir == "left" or gdir == "right":
		direction = Input.get_axis("ui_up", "ui_down")
		if direction:
			self.velocity.y = direction * SPEED * slowfactor
		else:
			self.velocity.y = stop(self.velocity.y)
func red(delta):
	directiony = Input.get_axis("ui_up", "ui_down")
	direction = Input.get_axis("ui_left", "ui_right")
	
	if directiony:
		velocity.y = directiony * SPEED * slowfactor
	else:
		velocity.y = stop(velocity.y)
	if direction:
		velocity.x = direction * SPEED * slowfactor
	else:
		velocity.x = stop(velocity.x)
func stop(vel):
	return vel*0.15
	
func disable():
	mode = "cutscene"
	hide()
	pass
	
func enable():
	mode = "red"
	show()
	pass
	
func intobattle():
	Sprite.modulate = redsoul
	position = Vector2(315,310)
	show()
	mode = "red"
	self.modulate.a = 0
	var tw =get_tree().create_tween()
	tw.tween_property(self,"modulate:a",1,0.3)


func intomenu(fightpos):
	Sprite.modulate = redsoul
	self.modulate.a = 1
	mode = "cutscene"
	var tw =get_tree().create_tween()
	tw.tween_property(self,"modulate:a",0,0.3)
	await tw.finished
	disable()
	self.position = Vector2(320,310)
func _on_bullet_area_entered(body):
	print("this is useless")
	return
func matchcolor(body):
	match body.mode:
		0:
			attempthurt()
		255:
			attempthurt()
		1:
			if ifpresskey():
				attempthurt()
		2:
			if !ifpresskey():
				attempthurt()
		3:
				attemptheal()
				
func attemptheal():
	bulletdamtemp = Game.matk
	heal(bulletdamtemp)
func attempthurt():
	bulletdamtemp = Game.matk
	hurt(bulletdamtemp)

var canheal = true
func heal(heal):
	if canheal:
		canheal = false
		healfx.play()
		hp += heal
		if hp> maxhp:
			hp = maxhp
func hurt(damage = 1):
	if canhurt:
		iframes = Game.hurtframe
		Camera.addshake(0.4)
		damage -= Game.def
		damage = max(damage,1)
		hp -= damage
		if Game.krbool:
			kr += damage
			if kr > hp -1:
				kr = hp -1
		hurtS.play()
		gui.refresh()
		if hp<=0:
			##DEATH
			canhurt = false
			emit_signal("predeath")
			$Soul/trail.hide()
			$Soul/trail2.hide()
			mode = "nomove"
			Camera.blinder.modulate.a = 1
			self.z_index = 101
			self.velocity = Vector2.ZERO
			var pos = self.position
			for i in 16:
				var tw = get_tree().create_tween()
				tw.tween_property(self,"position",Vector2(pos.x-randf_range(-3-i,3+i),pos.y-randf_range(-3-i,3+i)),0.05)
				Camera.addshake(0.14)
				await tw.finished
			Sprite.texture = load(soul_split)
			if soultype == "monster":
				Sprite.scale.y = -1
			$Crack.play()
			Camera.addshake(0.4)
			Sprite.hide()
			$Explode.play()
			$Shards.restart()
			$Shards.process_material.color = Sprite.modulate
			$Shards.emitting = true
			Camera.addshake(1.3)
			await get_tree().create_timer(1.5).timeout
			get_tree().change_scene_to_file("res://Menu/death_screen.tscn")
			return
		
func _on_bullet_area_exited(body):
	print("stop it")
	return



