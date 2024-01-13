extends Node2D

@onready var hpbar = $slash/Hp/Bar
@onready var barbg = $slash/Hp
@onready var Boss = get_node("/root/main/boss")
@onready var f = $FightBar
@onready var meter = $FightBar/Meter
@onready var bar = $Bar
@onready var bars = $Bar/Bar
@onready var banim = $AnimationPlayer2
var enabled = 0
var moving = 0
@onready var dams = $slash/dmg/dmg/NORMAL
@onready var damsH = $slash/dmg/dmg/HARD
@onready var Anim = $AnimationPlayer
@onready var slash = $slash
@onready var anim = $slash/dmg/AnimationPlayer
@onready var dmg = $slash/dmg/dmg
@onready var defaultpos = dmg.position
var mult = 1
var kb = false
const middle = 206
var barvel = 700
@export var meterTex = "res://BattleEngine/DamageMeter/meter.png"

# Called when the node enters the scene tree for the first time.
func _ready():
	hpbar.max_value = Game.mmaxhp
	hpbar.value = hpbar.max_value
	meter.texture = load(meterTex)
	barbg.hide()
	bar.hide()
	self.modulate = Color.WHITE
	enabled = true
	moving = false
	bar.position.x = 0
	enabled = false
	f.hide()
	pass # Replace with function body.

func knock():
	var t = get_tree().create_tween()
	var t2 = get_tree().create_tween()
	t.tween_property(Boss,"position:y",Boss.position.y+mult,0.45).set_trans(Tween.TRANS_QUAD)
	t2.tween_property(Boss,"scale",Boss.scale-Vector2(0.07,0.07)*mult,0.5).set_trans(Tween.TRANS_QUAD)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if enabled:
		if moving:
			#var tween = get_tree().create_tween()
			bar.velocity.x = barvel
			if Input.is_action_pressed("Confirm"):
				moving = false
				anim.play("slash")
				banim.play("glow")
				bar.velocity.x = 0
				slash.show()
				if Boss.dodging:
					Boss.dodge()
				await anim.animation_finished
				if !Boss.dodging:
					damage(calculate(Game.atk,Game.mdef))
				else:
					endslash(0)
					slash.frame = 6
					anim.play("move")
					if kb:
						knock()
					dmg.modulate = Color.GRAY
					dmg.text = "BLOCKED"
				enabled = false
				await get_tree().create_timer(1.5,false).timeout
				bars.frame = 0
				var tween = get_tree().create_tween()
				tween.tween_property(meter,"modulate:a",0,0.4)
				await tween.finished
				Anim.stop()
			if bar.global_position.x > 640:
				bar.velocity.x = 0
				moving = false
				slash.show()
				damage(0,true)
				await get_tree().create_timer(1.5,false).timeout
				var tween = get_tree().create_tween()
				tween.tween_property(meter,"modulate:a",0,0.4)
		bar.move_and_slide()
	#dmgvel.move_and_slide()

func start():
	bar.position.x = 0
	meter.modulate = Color.WHITE
	enabled = true
	Anim.play("Start")
	await get_tree().create_timer(0.1,false).timeout
	f.show()
	await Anim.animation_finished
	bar.show()
	moving = true

func calculate(atk = 10,def = 0):
	hpbar.show()
	var dist
	dist = abs(bar.global_position.x - 320) #distance
	if dist <= 48:
		dist = 40
	var do= round((atk - def + randf_range(0,2))* (120/dist))
	if do < 0:
		do = 0
	return do

func damage(amt,miss = false):
	hpbar.show()
	if !miss:
		##HIT
		if amt && amt > 0:
			if kb:
				knock()
			UpdateHpBar(amt)
			dmg.text = str(amt)
			dmg.modulate = Color.RED
			dams.play()
	##MISS
	else:
		dmg.text = "MISSED"
		dmg.modulate = Color.GRAY
	slash.frame = 6
	anim.play("move")
	endslash(amt)
	
func endslash(amt):
	Boss.damaged(amt)
	await get_tree().create_timer(1.5,false).timeout
	var tween = get_tree().create_tween()
	tween.tween_property(dmg,"position:y",defaultpos.y,0.2)
	var tween2 = get_tree().create_tween()
	tween2.tween_property(self,"modulate:a",0,0.4)
	dmg.text = ""
	await  tween2.finished
	bars.frame = 0
	bar.position.x = 0
	banim.stop()
	slash.hide()
	bar.hide()
	barbg.hide()
	Anim.play("RESET")

func UpdateHpBar(dmg):
	barbg.show()
	Game.mhp -= dmg
	if dmg >0:
		Boss.hurt()
		var t = get_tree().create_tween()
		t.tween_property(hpbar,"value",Game.mhp,0.5).set_trans(Tween.TRANS_QUAD)
