extends Enemy
@onready var musI = $Intro
@onready var musB = $Music
@onready var musE = $End

@export var debugattack = 0
@export var cutscene = false
func mute():
	musB.stop()
	musE.stop()
func init():
	Name = "papyrus"
	attacknum = debugattack
	head.frame = 3
	#init music:
	if cutscene:
		$Intro.play()
	else:
		$Music.play()
func dialogue():
	killmessage = false
	match attacknum:
		0:
			speak(0,2)
		1:
			speak(3,4)
		2:
			speak(5,6)
		3:
			speak(7,7)
		4:
			speak(8,9)
		5:
			speak(10,11)
		6:
			speak(12,13)
		7:
			speak(14,15)
func defhurt():
	pass
	
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

@onready var leftarm = $Sprites/Upper/L_arm
@onready var rightarm = $Sprites/Upper/R_arm
func throwanim(dir):
	match dir:
		"down":
			leftarm.frame = 3
			await get_tree().create_timer(0.05).timeout
			leftarm.frame = 2
			await get_tree().create_timer(0.15).timeout
			leftarm.frame = 3
			emit_signal("finishthrow")
			await get_tree().create_timer(0.2).timeout
			leftarm.frame = 0
		"up":
			leftarm.frame = 3
			await get_tree().create_timer(0.1).timeout
			leftarm.frame = 2
			emit_signal("finishthrow")
			await get_tree().create_timer(0.2).timeout
			leftarm.frame = 3
			await get_tree().create_timer(0.1).timeout
			leftarm.frame = 0
		"left":
			leftarm.frame = 5
			await get_tree().create_timer(0.1).timeout
			leftarm.frame = 4
			emit_signal("finishthrow")
			await get_tree().create_timer(0.2).timeout
			leftarm.frame = 5
			await get_tree().create_timer(0.1).timeout
			leftarm.frame = 0
		"right":
			leftarm.frame = 5
			await get_tree().create_timer(0.05).timeout
			leftarm.frame = 4
			await get_tree().create_timer(0.15).timeout
			leftarm.frame = 5
			emit_signal("finishthrow")
			await get_tree().create_timer(0.1).timeout
			leftarm.frame = 0
			
		"rightalt":
			rightarm.frame = 5
			await get_tree().create_timer(0.1).timeout
			rightarm.frame = 4
			emit_signal("finishthrow")
			await get_tree().create_timer(0.2).timeout
			rightarm.frame = 5
			await get_tree().create_timer(0.1).timeout
			rightarm.frame = 0
			
			
	
