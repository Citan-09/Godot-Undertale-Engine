extends sansfight

@export var color1 = Color("ffcad6")
@export var color0 = Color("ffffff")

var finishedfight = false
@onready var woosh = $SummonBone
@onready var womp = $SummonSpear
@onready var aueo = $Warning
var bosspos
	
func switchattack(turnnum = 0):
	bosspos = Boss.sprites.position
	Box.leavemenu()
	await get_tree().create_timer(1,false).timeout
	match turnnum:
		0:
			for i in lightarray:
				i.modulate = color0
			run_on_intro()
			startattack()
		1:
			attack2()
		2:
			attack3()
		3:
			attack4()
		4:
			attack5()
		5:
			attack6()
		6:
			attack7()
		7:
			for i in lightarray:
				i.modulate = color1
			finalattack()
		8:
			Boss.z_index = -6
			var tw = get_tree().create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
			tw.tween_property(Boss.sprites,"velocity:y",250,1)
			$fall.play()
			Camera.blind(0.3)
			await Camera.faded
			await get_tree().create_timer(0.4,false).timeout
			Camera.unblind(0.2)
			video.get_child(0).play()
			await video.get_child(0).finished
			Camera.blind(0.4)
			await Camera.faded
			##UNLOCK FIGHT
			Data.unlockedfights.merge({"sans":true},true)
			Data._savegame()
			Camera.blind(1)
			Camera.glitch(1)
			await Camera.faded
			get_tree().change_scene_to_file("res://Shared/overworld/snowdin.tscn")
				
		32767:
			if Boss.attacknum>0:
				healattack()
			else:
				endattack()
	
	currentattack += 1
	
		
func fademusic(select: String):
	if select == "Battle":
		var t1 = get_tree().create_tween()
		var t2 = get_tree().create_tween()
		t1.tween_property(Boss.musT,"volume_db",0,0.1)
		t2.tween_property(Boss.musI,"volume_db",-80,0.1)
		Boss.musT.play()
		await Boss.musT.finished
		Boss.musB.play()
		
	if select == "End":
		Boss.musE.play()
		var t1 = get_tree().create_tween()
		var t2 = get_tree().create_tween()
		t1.tween_property(Boss.musE,"volume_db",0,0.2)
		t2.tween_property(Boss.musB,"volume_db",-80,0.2)
		await get_tree().create_timer(0.2,false).timeout
		Boss.musB.stop()
	
func run_on_intro():
	if fighting == false:
		fighting = true
		fademusic("Battle")
		await get_tree().create_timer(15,false).timeout
		var t = get_tree().create_tween()
		t.tween_property(Camera,"zoom",Vector2(2,2),2).set_trans(Tween.TRANS_SPRING)
		var t2 = get_tree().create_tween()
		t2.tween_property(Blinder,"modulate:a",1,2).set_trans(Tween.TRANS_QUAD)
		Player.velocity = Vector2.ZERO
		await get_tree().create_timer(3.5,false).timeout
		t2 = get_tree().create_tween()
		t2.tween_property(Camera,"zoom",Vector2(1,1),1).set_trans(Tween.TRANS_BACK)
		t = get_tree().create_tween()
		t.tween_property(Blinder,"modulate:a",0,0.8).set_trans(Tween.TRANS_QUAD)


func startattack():
	boxsize(250,90)
	await get_tree().create_timer(0.7,false).timeout
	throw("down")
	await get_tree().create_timer(0.4,false).timeout
	for i in 8:
		if i == 6:
			await get_tree().create_timer(0.4,false).timeout
			throw("up")
			summonbones(0,90,350,0,80,180,0,112)
			summonbones(250,90,-350,0,80,180,0,112)
		
		await get_tree().create_timer(0.3,false).timeout
		summonbones(0,90,350,0,35,180)
		summonbones(250,90,-350,0,35,180)
		summonbones(240,0,-330,0,35,0)
		summonbones(0,0,330,0,35,0)
		await get_tree().create_timer(0.04,false).timeout
		summonbones(0,0,340,0,80,0,1).trans = Tween.TRANS_BOUNCE
		summonbones(250,0,-340,0,80,0,1).trans = Tween.TRANS_BOUNCE
		await get_tree().create_timer(0.25,false).timeout

	summonbones(-10,90,300,0,100,180,2)
	await get_tree().create_timer(0.7,false).timeout
	summonblaster(0,300,270,4,0.8,2)
	throw("down")
	await get_tree().create_timer(0.2,false).timeout
	summonbones(0,90,350,0,20,180).trans = Tween.TRANS_BACK
	await get_tree().create_timer(0.4,false).timeout
	boxsize(350,250,0,50)
	await get_tree().create_timer(0.7,false).timeout
	for i in allbones.get_children():
		i.fire(0,350)
	setmode("red")
	
	await get_tree().create_timer(0.6,false).timeout
	
	warn(600,50,175,125,0.6)
	warn(50,600,175,125,0.6)
	
	await get_tree().create_timer(0.5,false).timeout
	woosh.play()
	summonbones(175,125,0,0,230).time = 0.3
	await get_tree().create_timer(0.15,false).timeout
	woosh.play()
	summonbones(175,125,0,0,230,90).time = 0.3
	await get_tree().create_timer(0.15,false).timeout
	woosh.play()
	summonbones(175,125,0,0,230,180).time = 0.3
	await get_tree().create_timer(0.15,false).timeout
	woosh.play()
	summonbones(175,125,0,0,230,270).time = 0.3
	await get_tree().create_timer(0.6,false).timeout
	
	for i in allbones.get_children():
		var tween= get_tree().create_tween()
		tween.tween_property(i,"rotation_degrees",720+i.rotation_degrees,4.5)

		
	for i in 18:
		if i == 17:
			summonblaster(320,150,0,2,4.8).duration = 0.2
		if i % 2 ==0:
			summonbones(0+i*6,0,0,5,250,0,1).trans = Tween.TRANS_BOUNCE
			await get_tree().create_timer(0.21,false).timeout
			summonbones(0,0+i*6,0,5,350,270,2).trans = Tween.TRANS_BOUNCE
			summonbones(-6+i*6,250,0,0,90+i*2,180,255).trans = Tween.TRANS_QUINT
		else:
			summonbones(350-i*6,0,0,5,250,0,2).trans = Tween.TRANS_BOUNCE
			summonbones(344-i*6,250,0,0,90+i*2,180,255).trans = Tween.TRANS_QUINT
			await get_tree().create_timer(0.21,false).timeout
	for i in allbones.get_children():
		if i.mode == 0:
			i.fire(0,300,10)
			var tween= get_tree().create_tween()
			tween.tween_property(i,"rotation_degrees",360+i.rotation_degrees,1)	
	
	await get_tree().create_timer(4,false).timeout
	
	throw("down")
	await get_tree().create_timer(0.3,false).timeout
	warn(1000,50,320,250,0.3)
	summonbones(0,250,450,0,50,180)
	summonbones(340,250,-450,0,50,180)
	

	await get_tree().create_timer(0.8,false).timeout
	summonbones(0,0,450,0,30)
	summonbones(340,0,-450,0,30)
	summonbones(0,0,350,0,30)
	summonbones(340,0,-350,0,30)
	summonbones(0,0,250,0,30)
	summonbones(340,0,-250,0,30)
	await get_tree().create_timer(0.3,false).timeout
	for i in allbones.get_children():
		if i.sizeto < 60:
			i.fire(0,-10,60)
	await get_tree().create_timer(0.3,false).timeout
	for i in allbones.get_children():
		if i.sizeto ==60:
			i.fire(0,-10,10)
	await get_tree().create_timer(0.5,false).timeout
	for i in allbones.get_children():
		woosh.play()
		if i.sizeto ==10:
			i.fire(0,500,100)
		elif i.mode !=255:
			i.fire(0,500-i.position.y)
	
	await get_tree().create_timer(0.65,false).timeout
	for i in allbones.get_children():
		if i.mode == 255:
			i.mode = 0
			if abs(i.global_position.x -310) < 120:
				i.fire(sign(i.global_position.x - 320)*-190,0,25)
			else:
				i.fire(sign(i.global_position.x - 320)*-180,0,200,1)
				
	await get_tree().create_timer(1.6,false).timeout
	throw("left")
	warn(50,600,0,125,0.5)
	await get_tree().create_timer(0.5,false).timeout
	summonbones(0,0,0,460,30,270)
	summonbones(0,250,0,-450,30,270)
	
	await get_tree().create_timer(0.5,false).timeout
	throw("right")
	warn(50,600,350,125,0.5)
	await get_tree().create_timer(0.5,false).timeout
	summonbones(350,0,0,460,30,90)
	summonbones(350,250,0,-450,30,90)
	await get_tree().create_timer(0.6,false).timeout
	setmode("red")
	
	summonbones(0,0,150,0,250,0,2)
	summonbones(350,0,-150,0,250,0,1)
	summonbones(250,0,-150,0,250,0,2)
	summonbones(150,0,150,0,250,0,1)
	await get_tree().create_timer(0.4,false).timeout
	boxsize(150,150,0,-40)
	await get_tree().create_timer(0.8,false).timeout
	for i in 6:
		summonbones(i*36,-50,0,0,80).trans = Tween.TRANS_BOUNCE
		await get_tree().create_timer(0.05,false).timeout
		summonbones(200,i*36,0,0,80,90).trans = Tween.TRANS_BOUNCE
		await get_tree().create_timer(0.1,false).timeout
	await get_tree().create_timer(0.3,false).timeout
	for i in allbones.get_children():
		if i.rotation_degrees ==0:
			i.fire(0,0,20)
		else:
			i.fire(0,0,20,0,90)
	await get_tree().create_timer(0.3,false).timeout
	for i in allbones.get_children():
		if i.rotation_degrees ==90:
			i.fire(-500,0,100,0,90)
		else:
			i.fire(0,500,100)
	await get_tree().create_timer(0.6,false).timeout
	endattack()

func healattack():
	boxsize(200,150)
	await get_tree().create_timer(1,false).timeout
	a2blaster(3,1)
	for i in 8:
		await get_tree().create_timer(1,false).timeout
		summonbones(-5,0,70,0,80,0).time = 0.1
		summonbones(200,150,-70,0,80,180).time = 0.1
		for l in allbones.get_children():
			if l.mode == 1:
				l.fire(0,60)
			if l.mode == 2:
				l.fire(0,-60)
	await get_tree().create_timer(1,false).timeout
	endattack()
func attack2():
	boxsize(120,150)
	direct("down")
	await get_tree().create_timer(1,false).timeout
	for i in 4:
		summonbones(0,5,0,0,120,270,1).trans = Tween.TRANS_BOUNCE
		summonbones(-5,150,80,0,30,180)
		summonbones(120,150,-80,0,30,180)
		
		summonbones(-5,0,80,0,105)
		summonbones(120,0,-80,0,105)
		await get_tree().create_timer(0.55,false).timeout
		for l in allbones.get_children():
			if l.mode == 1:
				woosh.play()
				l.fire(0,100)
		await get_tree().create_timer(0.15,false).timeout
	setmode("red")
	await get_tree().create_timer(1.2,false).timeout
	boxsize(300,150,0,50,0.65)
	for i in allbones.get_children():
		i.queue_free()
	await get_tree().create_timer(0.1,false).timeout
	a2blaster(4,1.2)
	for i in 12:
		if i % 6==0:
			summonbones(0,5,0,0,200,270,1).trans = Tween.TRANS_BOUNCE
		if i % 6==3:
			summonbones(300,145,0,0,200,90,2).trans = Tween.TRANS_BOUNCE
		await get_tree().create_timer(1,false).timeout
		summonbones(-5,0,70,0,80,0).time = 0.1
		summonbones(300,150,-70,0,80,180).time = 0.1
		for l in allbones.get_children():
			if l.mode == 1:
				l.fire(0,60)
			if l.mode == 2:
				l.fire(0,-60)
	await get_tree().create_timer(3.8,false).timeout
	throw("down")
	await get_tree().create_timer(0.2,false).timeout
	warn(600,80,0,150,0.5)
	await get_tree().create_timer(0.35,false).timeout
	woosh.play()
	for i in 30:
		summonbones((i+1)*10,160,0,0,50,180).time = 0.35
	await get_tree().create_timer(0.4,false).timeout
	for i in allbones.get_children():
		i.fire(0,20,0)
	await get_tree().create_timer(0.25,false).timeout
	endattack()
	
func attack3():
	boxsize(400,150,0,0,0.35)
	throw("down")
	asyncplatform(18,1)
	await get_tree().create_timer(1,false).timeout
	warn(600,80,100,150,0.5)
	warn(600,80,100,0,0.5)
	await get_tree().create_timer(0.5,false).timeout
	woosh.play()
	for i in 40:
		summonbones(i*10,150,0,0,40,180)
		summonbones(i*10,0,0,0,40)
	for i in 8:
		await get_tree().create_timer(1.8,false).timeout
		summonbones(-10,150,150,0,75,180)
		summonbones(400,150,-150,0,75,180)
		
		summonbones(-30,0,150,0,115,0,1)
		summonbones(420,150,-150,0,115,180,2)
		
		summonbones(-10,0,150,0,60)
		summonbones(400,0,-150,0,60)
		woosh.play()
	await get_tree().create_timer(3,false).timeout
	for i in allbones.get_children():
		if i.vel == Vector2(0,0):
			i.fire(0,0,-20)
		else:
			i.fire(150,0)
		woosh.play()
	await get_tree().create_timer(0.6,false).timeout
	for i in allbones.get_children():
		if i.sizeto == -20:
			i.queue_free()
	await get_tree().create_timer(0.85,false).timeout
	boxsize(200,100)
	await get_tree().create_timer(2,false).timeout
	for i in 2:
		woosh.play()
		summonbones(240,0,-140,0,100,0,1)
		await get_tree().create_timer(0.8,false).timeout
	for i in 10:
		summonbones(-50,100,150,0,40,180).time = 0.2
		summonbones(240,0,-150,0,75).time = 0.2
		await get_tree().create_timer(0.68,false).timeout
	await get_tree().create_timer(0.8,false).timeout
	endattack()
	
func attack4():
	throw("left")
	await get_tree().create_timer(0.5,false).timeout
	warn(100,800,0,0,0.3)
	await get_tree().create_timer(0.3,false).timeout
	for i in 30:
		summonbones(0,i*10,0,0,50,270,0).time = 0.2
	await get_tree().create_timer(0.4,false).timeout
	direct("down")
	for i in allbones.get_children():
		i.queue_free()
	warn(60,800,0,0,0.5)
	Box.changesizex(200,0,8)
	await get_tree().create_timer(0.2,false).timeout
	summonbones(-10,0,5,0,140)
	for i in 17:
		if i %4 ==0:
			var rot = Extra.returnrotationdeg(Player.position,Vector2(Player.position.x,100))
			summonblaster(Player.position.x,100,rot,1.5,0.6)
		if i %2 == 0:
			summonbones(570,140,-200,0,40,180)
		else:
			summonbones(570,0,-200,0,105)
		await get_tree().create_timer(0.35,false).timeout
	await get_tree().create_timer(0.3,false).timeout
	summonbones(-20,140,140,0,150,180,1)
	await get_tree().create_timer(2.9,false).timeout
	for i in allbones.get_children():
		i.time = 1.2
		i.fire(0,0,0)
	await get_tree().create_timer(1,false).timeout
	for i in allbones.get_children():
		i.queue_free()
	boxsize(200,200,0,50)
	await get_tree().create_timer(1,false).timeout
	warn(50,200,100,100,0.6)
	await get_tree().create_timer(0.5,false).timeout
	summonbones(100,200,0,0,55,180)
	summonbones(100,0,0,0,100)
	for i in 7:
		summonbones(0,0,0,0,200,270,1).trans = (Tween.TRANS_BOUNCE)
		var randn = randi_range(0,1)
		summonblaster(270+randn*100,180,0,4)
		await get_tree().create_timer(0.5,false).timeout
		for b in allbones.get_children():
			if b.mode == 1:
				b.fire(0,115)
		await get_tree().create_timer(0.6,false).timeout
		summonbones(0,200,300,0,20,180,0).time= 0.2
		summonbones(200,200,-300,0,20,180,0).time = 0.2
		await get_tree().create_timer(0.4,false).timeout
	await get_tree().create_timer(0.6,false).timeout
	endattack()
		
func attack5():
	summonbones(0,135,0,0,580,270,2)
	var plat = summonplatform(320,500,575/2.0,110)
	await get_tree().create_timer(0.6,false).timeout
	summonbones(0,125,0,0,580,270,1)
	direct("down")
	plat.update(-50,0)
	a5dot2()
	await get_tree().create_timer(2.5,false).timeout
	plat.update(50,0,"pink")
	await get_tree().create_timer(4.5,false).timeout
	plat.update(-50,0,"green")
	await get_tree().create_timer(2.5,false).timeout
	summonbones(0,140,150,0,140,180,2)
	summonbones(580,140,-150,0,140,180,2)
	await get_tree().create_timer(2,false).timeout
	for i in allbones.get_children():
		i.time = 1.5
		i.changesize(0)
	await get_tree().create_timer(1,false).timeout
	for i in allbones.get_children():
		i.fire(i.vel.x,50)
	Box.changesizex(100,0,8)
	setmode("red")
	a2blaster(10,1,0.7)
	await get_tree().create_timer(7.5,false).timeout
	direct("down")
	boxsize(500,200,0,60,0.5)
	await get_tree().create_timer(1,false).timeout
	for i in 20:
		summonbones(0-i*10,200,150,0,50,180)
	for i in 10:
		summonbones(-200-i*10,200,150,0,100,180)
	summonbones(-500,0,190,0,105)
	for i in 10:
		summonbones(-300-i*10,200,150,0,50,180)
	for i in 40:
		if i % 12 ==0&& i> 11:
			summonbones(-400-i*10,200,150,0,100,180)
			summonbones(-400-i*10,0,150,0,85)
		else:
			summonbones(-400-i*10,200,150,0,50,180)
		
	summonplatform(0,480,0,140).update(150,0)
	summonplatform(0,500,-200,100,"green",25).update(156,0,"green")
	for i in 3:
		summonplatform(0,480,-250-i*150,140).update(150,0)
	await get_tree().create_timer(5.6,false).timeout
	summonblaster(320,100,0,25,0.6,1)
	await get_tree().create_timer(1,false).timeout
	endattack()
		
func a5dot2():
	for i in 8:
		if i > 5:
			summonbones(0,0,150,0,100,0,1)
			summonbones(580,0,-150,0,100,0,1)
		summonbones(0,140,200,0,50,180)
		summonbones(580,140,-200,0,50,180)
		await get_tree().create_timer(0.5,false).timeout
		summonbones(0,0,200,0,85)
		summonbones(580,0,-200,0,85)
		await get_tree().create_timer(0.5,false).timeout
	
func attack6():
	direct("down")
	Box.changesizex(350)
	await get_tree().create_timer(1,false).timeout
	summonbones(0,0,100,0,110,0).time = 3
	for i in 4:
		var t = summonbones(340-i*10,0,0,0,140)
		t.trans = Tween.TRANS_BOUNCE
		t.tag = "right"
		summonbones(0,140,200,0,85,180).time = 1.4
		summonbones(420,140,-200,0,70,180).time = 1.4
		await get_tree().create_timer(0.07,false).timeout
		if i ==0:
			summonbones(-50,0,200,0,140,0,1).time = 1.5
			summonbones(465,0,-200,0,140,0,1).time = 2
	await get_tree().create_timer(0.85,false).timeout
	for i in 2:
		var b = summonbones(-200-i*2,140,200,0,50,180)
		b.bone.size.y += i*8
		b.time = 4
		await get_tree().create_timer(0.07,false).timeout
	for i in 3:
		var b = summonbones(620-i*2,140,-250,0,80,180)
		b.bone.size.y += i*10
		b.time = 3
		await get_tree().create_timer(0.07,false).timeout
	await get_tree().create_timer(1.9,false).timeout
	for i in 5:
		summonbones(-50,140,300,0,24,180)
		summonbones(400,140,-300,0,24,180)
		summonbones(0,0,250,0,106).trans = Tween.TRANS_BOUNCE
		summonbones(350,0,-250,0,106).trans = Tween.TRANS_BOUNCE
		await get_tree().create_timer(0.6,false).timeout
	await get_tree().create_timer(1,false).timeout
	for i in allbones.get_children():
		if i.tag == "right":
			i.fire(0,0,124)
	summonbones(400,140,-250,0,40,180)
	summonbones(540,140,-250,0,40,180)
	summonbones(470,0,-250,0,100,0)
	summonbones(-160,0,150,0,140,0).tag = "remove"
	summonbones(560,0,-250,0,140,0,1).trans = Tween.TRANS_BOUNCE
	await get_tree().create_timer(2.85,false).timeout
	for i in allbones.get_children():
		if i.tag == "remove":
			i.fire(150,0,120)
	await get_tree().create_timer(0.4,false).timeout
	Camera.blinder.modulate.a = 1
	Box.changesize(350,140,-140,80,0.1)
	for i in 2:
		$noise.play()
		await get_tree().create_timer(0.2,false).timeout
	Camera.blinder.modulate.a = 0
	await get_tree().create_timer(0.4,false).timeout
	warn(50,140,325,70,0.5)
	await get_tree().create_timer(0.5,false).timeout
	var tempinc = 0
	for i in allbones.get_children():
		if i.tag == "right":
			tempinc += 1
			i.fire(-60,0,140)
			var tw = get_tree().create_tween().set_trans(Tween.TRANS_CIRC)
			tw.tween_property(i.bone,"size:y",60,3)
	
		if i.tag == "remove":
			i.fire(-120,0,140,1)
	summonbones(0,140,200,0,140,180).tag = "a1"
	summonbones(350,140,-200,0,140,180).tag = "a2"
	await get_tree().create_timer(0.45,false).timeout
	for i in allbones.get_children():
		if i.tag == "a1" or i.tag == "a2":
			var tw = get_tree().create_tween()
			tw.tween_property(i,"offset:y",-40,0.6)
			var tw2 = get_tree().create_tween()
			tw2.tween_property(i,"vel:x",0,0.4)
			tw2.tween_property(i,"size:y",40,0.5)
			tw2.tween_property(i,"size:y",100,0.5)
		var twr = get_tree().create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		if i.tag == "a2":
			twr.tween_property(i,"rotation_degrees",360,1)
		if i.tag == "a1":
			twr.tween_property(i,"rotation_degrees",0,1)
	await get_tree().create_timer(1.36,false).timeout
	for i in allbones.get_children():
		if i.tag == "a1":
			i.fire(250,0,)
		if i.tag == "a2":
			i.fire(-250,0)
	await get_tree().create_timer(1.1,false).timeout
	a2blaster(3,1.2,0.6)
	await get_tree().create_timer(3,false).timeout
	bigwarning("left")
	await get_tree().create_timer(0.3,false).timeout
	boxsize(300,50,250,-50,0.5)
	await get_tree().create_timer(0.8,false).timeout
	for i in 9:
		summonbones(300,50,-200,0,50,180,randi_range(1,2))
		await get_tree().create_timer(0.3,false).timeout
	await get_tree().create_timer(1.6,false).timeout
	endattack()

func attack7():
	await get_tree().create_timer(0.2,false).timeout
	direct("down")
	Box.changesizex(350)
	await get_tree().create_timer(0.75,false).timeout
	for i in 6:
		var randh = randi_range(1,3)*15
		summonbones(-20,140,250,0,25+randh,180).time = 0.1
		summonbones(370,140,-250,0,25+randh,180).time = 0.1
		summonbones(-20,0,250,0,100-randh).time = 0.1
		summonbones(370,0,-250,0,100-randh).time = 0.1
		await get_tree().create_timer(1+0.008*randh,false).timeout
		if i == 4:
			summonblaster(Player.position.x,150,0,1.2,0.8)
			await get_tree().create_timer(0.6,false).timeout
	await get_tree().create_timer(0.5,false).timeout
	var t = get_tree().create_tween()
	t.tween_property(Camera,"degrotation",180,0.3).set_trans(Tween.TRANS_CUBIC)
	throw("up")
	await get_tree().create_timer(0.4,false).timeout
	for i in 6:
		var randh = randi_range(1,3)*15
		summonbones(-20,140,250,0,95-randh,180).time = 0.1
		summonbones(370,140,-250,0,95-randh,180).time = 0.1
		summonbones(-20,0,250,0,30+randh).time = 0.1
		summonbones(370,0,-250,0,30+randh).time = 0.1
		if i >3:
			summonbones(-50,140,250,0,140,180,1).time = 0.1
			summonbones(400,140,-250,0,140,180,1).time = 0.1
		if i >4:
			summonblaster(Player.position.x,150,0,1.2,1.35)
			await get_tree().create_timer(1.15,false).timeout
		await get_tree().create_timer(1+0.008*randh,false).timeout
	await get_tree().create_timer(1,false).timeout
	t = get_tree().create_tween()
	t.tween_property(Camera,"degrotation",0,0.3).set_trans(Tween.TRANS_CUBIC)
	await t.finished
	boxsize(200,200,0,50,0.3)
	throw("down")
	await get_tree().create_timer(0.5,false).timeout
	for i in 4:
		warn(10,250,100,100,0.5,45+i*90)
	warn(10,250,100,100,0.5,90)
	await get_tree().create_timer(0.6,false).timeout
	summonbones(100,100,0,0,100,45).tag = "r1"
	summonbones(100,100,0,0,100,225).tag = "r1"
	summonbones(100,100,0,0,100,135).tag = "r2"
	summonbones(100,100,0,0,100,315).tag = "r2"
	
	summonbones(100,100,0,0,100,270).tag = "r3"
	summonbones(100,100,0,0,100,90).tag = "r4"
	
	for i in allbones.get_children():
		if i.tag == "r3"or i.tag =="r4":
			i.offset.y = 60
		else:
			i.offset.y = 80
	await get_tree().create_timer(0.4,false).timeout
	for i in allbones.get_children():
		if i.tag == "r1":
			var tweenrotation = get_tree().create_tween()
			tweenrotation.tween_property(i,"rotation_degrees",i.rotation_degrees+9256.5,45)
			tweenrotation.tween_property(i,"rotation_degrees",i.rotation_degrees+9666,2)
			tweenrotation.tween_property(i,"rotation_degrees",i.rotation_degrees+9871,2)
		if i.tag == "r2":
			var tweenrotation = get_tree().create_tween()
			tweenrotation.tween_property(i,"rotation_degrees",i.rotation_degrees-9256.5,45)
			tweenrotation.tween_property(i,"rotation_degrees",i.rotation_degrees-9666,2)
			tweenrotation.tween_property(i,"rotation_degrees",i.rotation_degrees-9871,2)
	await  get_tree().create_timer(0.3,false).timeout
	for l in 10:
		var twp = get_tree().create_tween()
		twp.tween_property(Boss.musB,"pitch_scale",Boss.musB.pitch_scale-(l)/150.0,6)
		if l > 4:
			Boss.head.frame = 3+l/5
		if l >0:
			if l %2 ==0:
				bigwarning("down")
			else:
				bigwarning("up")
		for i in allbones.get_children():
			if i.tag == "r3":
				var tweenrotation = get_tree().create_tween()
				tweenrotation.tween_property(i,"rotation_degrees",i.rotation_degrees-960,3.5)
				if l %2 == 0:
					i.fire(0,0,200,1)
				else:
					i.fire(0,0,200,2)
				womp.play()
				var tweenoffset = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC)
				tweenoffset.tween_property(i,"offset:y",5,0.3)
			if i.tag == "r4":
				var tweenrotation = get_tree().create_tween()
				tweenrotation.tween_property(i,"rotation_degrees",i.rotation_degrees+960,3.5)
				if l %2 == 0:
					i.fire(0,0,200,1)
				else:
					i.fire(0,0,200,2)
				womp.play()
				var tweenoffset = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC)
				tweenoffset.tween_property(i,"offset:y",5,0.3)
		
		await get_tree().create_timer(1.5,false).timeout
		for i in allbones.get_children():
			if i.tag == "r4" or i.tag == "r3":
				var tweenoffset = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC)
				tweenoffset.tween_property(i,"offset:y",60,0.3)
		await get_tree().create_timer(3,false).timeout
	var twp = get_tree().create_tween()
	twp.tween_property(Boss.musB,"pitch_scale",0,2)
	var twv = get_tree().create_tween()
	twv.tween_property(Boss.musB,"volume_db",-36,2)
	endattack()

func finalattack():
	Fight.mult = 8
	Boss.dodging = false
	Game.mdef = -70
	Camera.finalityend()
	boxsize(300,300,0,100)
	fademusic("End")
	var twz = get_tree().create_tween()
	twz.tween_property(Camera,"zoom",Vector2(1.5,1.5),1.6)
	await get_tree().create_timer(1.5,false).timeout
	var tw = get_tree().create_tween()
	tw.tween_property(Box,"rotation_degrees",360*3,14)
	bg.back.show()
	for i in 100:
		var t=0
		if i %20 ==0:
			t = 80
			var c = summonbones(300,300,-100,0,200,180,2)
			c.dir = "left"
			c.limit = -1
		var r = summonbones(0,0,100,0,80+i/50.0+t)
		r.dir = "right"
		r.limit = Box.size.x
		
		t=0
		if i %20 ==5:
			t = 80
		r = summonbones(300,30,0,100,80+t,90)
		r.dir = "down"
		r.limit = Box.size.x
		
		t=0
		if i %20 ==10:
			t = 80
			var c = summonbones(0,300,100,0,200,180,1)
			c.dir = "right"
			c.limit = Box.size.x
		r = summonbones(300,300,-100,0,80+i/50.0+t,180)
		r.dir = "left"
		r.limit = -1
		
		t=0
		if i %20 ==15:
			t = 80
		r = summonbones(0,300,0,-100,80+t,270)
		r.dir = "up"
		r.limit = -1
		await get_tree().create_timer(0.1,false).timeout
	await get_tree().create_timer(1.6,false).timeout
	bigwarning("down",true,1)
	warn(300,80,150,260,0.6)
	await get_tree().create_timer(1,false).timeout
	for i in 30:
		summonbones(10+i*10,300,0,0,80,180).tag = "scare"
	await get_tree().create_timer(0.4,false).timeout
	Camera.blind(0.4)
	var twc = get_tree().create_tween()
	twc.tween_property(Camera,"zoom",Vector2(2,2),0.5)
	$noise.play()
	Box.changesizey(200,0,0.5)
	Box.changesizex(4000,-1800,0.5)
	for i in allbones.get_children():
		if i.tag == "scare":
			i.queue_free()
	direct("right")
	Boss.looping = true
	var twg = get_tree().create_tween()
	twg.tween_property(Player,"slammult",0.32,0.3)
	await get_tree().create_timer(0.5,false).timeout
	
	twc.tween_property(Camera,"zoom",Vector2(1.5,1.5),0.4)
	bg.hide()
	get_node("/root/main").remove_child(Camera)
	Player.add_child(Camera)
	Camera.position = Vector2.ZERO
	$noise.play()
	Camera.unblind(0.2)
	Boss.sprites.velocity.x = -250
	for i in 9:
		if i % 2 ==0:
			for b in 5:
				summonbones(1200+b*10,0,-500,0,120+i,0).limit = 69
		else:
			for b in 5:
				summonbones(1200+b*10,200,-500,0,120+i,180).limit = 69
		await get_tree().create_timer(0.65,false).timeout
	twz = get_tree().create_tween()
	twz.tween_property(Camera,"zoom",Vector2(1,1),1.6)
	await get_tree().create_timer(0.7,false).timeout
	for i in 80:
		summonbones(3000-i*28,0,-500,0,90-sin(i/12.0)*40,0).limit = 69
		summonbones(3000-i*28,200,-500,0,90+sin(i/12.0)*40,180).limit = 69
	await get_tree().create_timer(2.5,false).timeout
	for i in 50:
		summonbones(2900-i*15,0,-500,0,93-i,0).limit = 69
		summonbones(2900-i*15,200,-500,0,93-i,180).limit = 69
	summonbones(3000,0,-510,0,100,0,1).limit = 69
	summonbones(3000,200,-510,0,100,180,1).limit = 69
	await get_tree().create_timer(3.5,false).timeout
	twg = get_tree().create_tween()
	twg.tween_property(Player,"slammult",15,0.8)
	twg.tween_interval(1.8)
	twg.tween_property(Boss.sprites,"velocity",Vector2.ZERO,2)
	
	await get_tree().create_timer(1.5,false).timeout
	for i in 3:
		summonbones(4000,0,0,250,40+randi_range(-15,15),90).limit = 69
		summonbones(4000,200,0,-250,40+randi_range(-15,15),90).limit = 69
		await get_tree().create_timer(0.5,false).timeout
	Camera.finalityend()
	await get_tree().create_timer(1.4,false).timeout
	Boss.sprites.position = bosspos
	boxsize(200,200,1800,0,0.1)
	Player.position = Vector2(320,300)
	setmode("red")
	bg.show()
	Player.remove_child(Camera)
	get_node("/root/main").add_child(Camera)
	Camera.position = Vector2(320,240)
	Boss.looping = false
	for i in 20:
		if randi_range(0,100) > 40:
			summonbones(200,200,randi_range(-140,-230),0,randi_range(180,60),180,1)
		elif randi_range(0,100)<82:
			summonbones(0,200,randi_range(140,230),0,randi_range(180,60),180,1)
		if randi_range(0,100) < 40:
			summonbones(200,0,randi_range(-140,-230),0,randi_range(180,60),0,1)
			if randi_range(0,50) > 10:
				summonbones(0,0,randi_range(140,230),0,randi_range(180,60),0,1)
		await get_tree().create_timer(0.3,false).timeout
	await get_tree().create_timer(0.2,false).timeout
	summonbones(0,200,35,0,20,180)
	await get_tree().create_timer(4,false).timeout
	var pos = Boss.sprites.position.x
	for i in 10:
		var t = get_tree().create_tween().set_trans(Tween.TRANS_QUINT)
		t.tween_property(Boss.sprites,"position:x",randf_range(pos-4,pos+4),0.06)
		await t.finished
	endattack()
	

func bigwarning(dir,throw=false,frame = 1):
	var tw = get_tree().create_tween()
	tw.tween_property(Boss.warning,"modulate:a",1,0.25)
	aueo.play()
	match dir:
		"left":
			Boss.warning.rotation_degrees = 180
		"right":
			Boss.warning.rotation_degrees = 0
		"down":
			Boss.warning.rotation_degrees = 90
		"up":
			Boss.warning.rotation_degrees = 270
	Boss.warning.frame = frame
	await aueo.finished
	tw = get_tree().create_tween()
	tw.tween_property(Boss.warning,"modulate:a",0.0,0.25)
	if !throw: direct(dir)
	else:throw(dir)

func asyncplatform(t,d,col = 'pink'):
	for i in t:
		summonplatform(50,250,0,105,col).update(100,0)
		await get_tree().create_timer(d,false).timeout
func a2blaster(times,size,time :float=3):
	for i in times:
		var randompos= Vector2(randf_range(100,540),randf_range(80,400))
		var rot = Extra.returnrotationdeg(Player.position,randompos)
		summonblaster(randompos.x,randompos.y,rot,size,0.8).duration = 0.4
		await get_tree().create_timer(time,false).timeout


