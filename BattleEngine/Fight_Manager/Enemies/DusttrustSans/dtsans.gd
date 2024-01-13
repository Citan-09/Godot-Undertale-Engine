extends Enemy
@onready var block = $Block
@onready var warning = $Warning
@onready var musI = $Intro
@onready var musT = $Into
@onready var musB = $Music
@onready var musE = $End

var looping = false
@export var debugattack = 0
func mute():
	musB.stop()
	musE.stop()
func init():
	attacknum = debugattack
	head.frame = 2
	#init music:
	if !attacks.fighting:
		$Intro.play()
func hurt():
	head.frame =1
func dialogue():
	killmessage = false
	match attacknum:
		0:
			speak(0,2)
		1:
			speak(3,4)
		2:
			speak(5,7)
			dodging = true
		3:
			speak(8,8)
		4:
			speak(9,11)
		5:
			speak(12,13)
		6:
			speak(14,15)
		7:
			speak(16,17)
	if attacknum > 7:
		emit_signal("finishspeech")
		emit_signal("attack",8)
func tick(delta):
	if looping && sprites.position.x < -640 + cam.global_position.x:
		sprites.position.x += 660 + cam.global_position.x
		if head.frame < 7:
			head.frame += 1
func dodge():
	var pos = sprites.position.x
	for i in 3:
		var t = get_tree().create_tween().set_trans(Tween.TRANS_QUINT)
		t.tween_property(sprites,"position:x",randf_range(pos-3,pos+3),0.06)
		await t.finished
	var t = get_tree().create_tween().set_trans(Tween.TRANS_QUINT)
	t.tween_property(sprites,"position:x",pos,0.06)
	block.play("Block")
	await get_tree().create_timer(1.2,false).timeout
	for i in 3:
		t = get_tree().create_tween().set_trans(Tween.TRANS_QUINT)
		t.tween_property(sprites,"position:x",randf_range(pos-3,pos+3),0.06)
		await t.finished
	t = get_tree().create_tween().set_trans(Tween.TRANS_QUINT)
	block.play("UnBlock")
	
@export var idletime = 2.0
@export var transtype = Tween.TRANS_QUAD
func idleanim():
	var t = get_tree().create_tween().set_trans(transtype)
	t.tween_property($Sprites/Upper,"position:y",$Sprites/Upper.position.y + 1,idletime)
	t.tween_property($Sprites/Upper,"position:y",$Sprites/Upper.position.y,idletime)
	var t2 = get_tree().create_tween().set_trans(transtype)
	t2.tween_property($Sprites/Upper2,"position:y",$Sprites/Upper2.position.y + 1.5,idletime)
	t2.tween_property($Sprites/Upper2,"position:y",$Sprites/Upper2.position.y,idletime)
	await t.finished
	idleanim()

