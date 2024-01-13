extends Node2D

@onready var txtbox = $OverworldDBox
@onready var cam = $Camparent/Camera2D
@onready var sans = $Sans
@onready var player = $PlayerOverworld
@onready var c = $Camparent
@onready var stage = $Stage
@onready var intobattle = $IntoFight
var mettapos = Vector2(100,-150)

var velocity = Vector2()
var interact = false

var limit:Vector4#x:left y:up z:right w:bottom
const camsize = Vector2(640,480)
var viewsize

func _process(delta):
	camcontroller(delta)
	if Input.is_action_just_pressed("Confirm") &&interact:
		txtbox.summon(c.position,"missing")

func focusto(string):
	focus = string
	match focus:
		"player":
			node = player
		"sans":
			node = sans
var focus = "player"
@onready var node = player
func camcontroller(delta):
	c.position = node.global_position
	checkifoutofbounds()
	
func IntoBattle():
	await txtbox.confirm
	sans.speed = 0
	$BlockBottom.show()
	stage.show()
	stage.modulate.a = 0
	var tween = get_tree().create_tween()
	tween.tween_property($BlockBottom,"modulate:a",1,0.3)
	var tween2 = get_tree().create_tween()
	tween2.tween_property(stage,"modulate:a",1,0.25)
	await tween2.finished
	stage.rise(400)
	var ppos = player.global_position
	remove_child(player)
	stage.topplat.add_child(player)
	player.global_position = ppos
	
	var spos = sans.global_position
	remove_child(sans)
	stage.topplat.add_child(sans)
	sans.global_position = spos
	player.col.disabled = true
	$Music.stop()
	tween = get_tree().create_tween()
	tween.tween_property($Ding,"volume_db",-6,0.5)
	await stage.finish
	cam.position_smoothing_enabled= false
	tween = get_tree().create_tween()
	tween.tween_property($Ding,"volume_db",-80,0.4)
	intobattle.intobattle(Vector2(320,240) ,"sans")
	
func _ready():
	player.togglemove(false)
	txtbox.holdbattle.connect(IntoBattle)
	txtbox.togglemove.connect(player.togglemove)
	cam.blinder.modulate.a = 1
	limit.x = -70
	limit.y = -5
	limit.z = 180
	limit.w = 150
	viewsize = camsize/cam.zoom
	cam.unblind(0.8)
	await cam.faded
	player.togglemove(true)
func checkifoutofbounds():
	if c.position.x < limit.x + viewsize.x/4:
		c.position.x = limit.x + viewsize.x/4
	if c.position.x > limit.z - viewsize.x/4:
		c.position.x = limit.z - viewsize.x/4
	if c.position.y < limit.y + viewsize.y/4:
		c.position.y = limit.y + viewsize.y/4
	if c.position.y > limit.w - viewsize.y/4:
		c.position.y = limit.w - viewsize.y/4
func mettaroom():
	player.togglemove(false)
	cam.blind()
	await cam.faded
	limit.x = -1000000
	limit.y = -1000000
	limit.z = 1000000
	limit.w = -150
	player.position = mettapos
	cam.unblind()
	await cam.faded
	player.togglemove(true)
func _on_go_into_boss_fight_body_entered(body):
	if body.is_in_group("player"):
		mettaroom()
		pass # Replace with function body.


func _on_say_no_body_entered(body):
	if body.is_in_group("player") &&!txtbox.boxissummon:
		txtbox.summon(c.position,"nomore")
	pass # Replace with function body.


func _enableinteract(body):
	if body.is_in_group("playerinteract") &&!txtbox.boxissummon:
		interact = true


func _disableinteract(body):
	if body.is_in_group("playerinteract"):
		interact = false

signal sansishere
var started =false

func _on_enter_fight_zone(body):
	if body.is_in_group("player")&&!started:
		started = true
		focusto("sans")
		player.togglemove(false)
		await get_tree().create_timer(0.6).timeout
		sans.canmove = true
		await sansishere
		txtbox.summon(c.position,"sansintro","sans")
	elif body.is_in_group("sans"):
		focusto("player")
		sans.canmove = false
		player.togglemove(false)
		await get_tree().create_timer(0.1).timeout
		emit_signal("sansishere")


func _no_goin_back(body):
	if body.is_in_group("player") &&!txtbox.boxissummon:
		txtbox.summon(c.position,"nogoingback")
