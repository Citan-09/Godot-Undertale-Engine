extends papyrusencounter
@onready var externalbones = $Bones
@onready var woosh = $SummonBone
@onready var womp = $SummonSpear
@onready var weesh = $SwingBone


func summonspike(posx=0,posy=0,targetpos=Vector2(0,0),speed=100,delay=0.2):
	var clone = spike.instantiate()
	clone.modulate.a = 0
	externalbones.add_child(clone)
	clone.position = Vector2(posx,posy)
	clone.fire(targetpos,delay,speed)
	return clone
	
func summonbonesexternal(posx= 0,posy = 420,velx = 300,vely= 0,size = 90,Rotation = 0,mode = 0,endx = null):
	var clone = bone.instantiate()
	clone.Sprite = "res://BattleEngine/Fight_Manager/Enemies/BonePapy.png"
	allbones.add_child(clone)
	clone.fire(velx,vely,size,mode,Rotation,endx)
	custombonecolor(clone)
	clone.position = Vector2(posx, posy) #+ Box.Rect.global_position
	var pos = clone.global_position
	allbones.remove_child(clone)
	externalbones.add_child(clone)
	clone.global_position = pos
	clone.limit = 69420
	return clone
	
func endattack():
	Box.returntomenu()
	setmode("nomove")
	Player.velocity = Vector2.ZERO
	for i in allbones.get_children()+externalbones.get_children()+allnotbones.get_children():
		i.queue_free()
	await get_tree().create_timer(Box.sizetime,false).timeout
	Butn.selected = 0
	Player.intomenu(Butn.get_child(0).global_position- Vector2(38,0))

func summonbones(posx= 0,posy = 420,velx = 300,vely= 0,size = 90,Rotation = 0,mode = 0,endx = null):
	var clone = bone.instantiate()
	clone.Sprite = "res://BattleEngine/Fight_Manager/Enemies/BonePapy.png"
	allbones.add_child(clone)
	clone.fire(velx,vely,size,mode,Rotation,endx)
	custombonecolor(clone)
	clone.position = Vector2(posx, posy) #+ Box.Rect.global_position
	return clone
	

func switchattack(turnnum=0):
	match turnnum:
		32767:
			Player.modeS.stop()
			Box.getturn()
			Player.disable()
			await get_tree().create_timer(0.02,false).timeout
			Butn.enable()
		0:
			attack1()
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
			attackfinal()
func attack1():
	await get_tree().create_timer(1,false).timeout
	throw("down")
	var b = []
	for i in 3:
		b.append(summonbones(570-i*10,-15,0,0,140))
		b[i].trans = Tween.TRANS_BOUNCE
	for i in 6:
		summonbones(-5,140,200,0,40,180)
		summonbones(-5,0,200,0,90)
		summonbones(670,140,-300,0,40,180).limit = 69
		summonbones(670,0,-300,0,90).limit = 69
		await get_tree().create_timer(0.75,false).timeout
	await get_tree().create_timer(0.2,false).timeout
	for i in b:
		i.fire(-220,0,120)
	warn(280,140,140,70,1)
	await get_tree().create_timer(1,false).timeout
	var bone = summonbones(0,140,0,0,140,180,0)
	var tw = get_tree().create_tween()
	tw.tween_property(bone,"global_position:x",320,0.8).set_trans(Tween.TRANS_QUAD)
	await get_tree().create_timer(0.5,false).timeout
	Player.showlabel()
	setmode("nomove")
	Player.velocity = Vector2.ZERO
	Game.tpcd = 1
	gui.tp.show()
	Player.get_node("RayCast2D").target_position= Vector2(-10000,0)
	await Player.get_node("RayCast2D").teleported
	Player.hidelabel()
	await get_tree().create_timer(0.2,false).timeout
	bone.fire(200,0,140,1)
	boxsize(100,250,0,40)
	setmode("red")
	await get_tree().create_timer(1,false).timeout
	for i in 4:
		woosh.play()
		var s = [summonbonesexternal(-98,-350,0,330,150,270),summonbonesexternal(198,630,0,-330,150,90)]
		for e in s:
			e.time = 0.1
		await get_tree().create_timer(0.8,false).timeout
		var bones = []
		var rand = randi_range(-2,2)
		var rand2 = randi_range(-2,2)
		womp.play()
		for l in 4:
			bones.append(summonbones(76-20*l,-30,0,0,50))
			bones[l].trans = Tween.TRANS_BOUNCE
		bones[rand].fire(0,0,50,1)
		bones[rand2].fire(0,0,50,1)
		await get_tree().create_timer(0.7,false).timeout
		for d in bones:
			weesh.play()
			d.fire(0,225)
		await get_tree().create_timer(0.4,false).timeout
	await get_tree().create_timer(1,false).timeout
	endattack()
func attackdot2(iter= 2,time = 0.7,width = Box.size.x,height= Box.size.y):
	for i in iter:
		var p1 = summonbones(10+i*10,0,0,0,250)
		p1.tag = "p"
		var p2= summonbones(width-10-i*10,0,0,0,250)
		p2.tag = "p"
		p1.trans = Tween.TRANS_BOUNCE
		p2.trans = Tween.TRANS_BOUNCE
		

func attack2():
	boxsize(150,250,0,50)
	await get_tree().create_timer(1.15,false).timeout
	attackdot2(3,2,150,250)
	var e
	for i in 30:
		if i%10 ==0:
			e =summonbonesexternal(0,-100,0,0,150,270,2)
		elif i%10 ==4:
			e.fire(0,200)
			e = null
		var s = sin(i/5.5)*70.0
		summonbones(-300,250,250,0,110+s,180)
		summonbones(-300,0,250,0,100-s)
		await get_tree().create_timer(0.12,false).timeout
	await get_tree().create_timer(1.25,false).timeout
	for i in 6:
		var ppos = Player.position - Box.position
		warnmark(ppos.x,ppos.y,0.5)
		await get_tree().create_timer(0.6,false).timeout
		woosh.play()
		if i %2 ==0:
			summonbones(ppos.x,0,0,0,250).trans = Tween.TRANS_BOUNCE
		else:
			summonbones(0,ppos.y,0,0,250,270).trans = Tween.TRANS_BOUNCE
		await get_tree().create_timer(0.4,false).timeout
	for i in allbones.get_children():
		i.trans = Tween.TRANS_QUAD
		i.fire(0,0,0)
	await get_tree().create_timer(0.3,false).timeout
	boxsize(200,200,0,-50)
	throw("down")
	await get_tree().create_timer(0.5,false).timeout
	var plat = summonplatform(0,300,100,140,"pink")
	await get_tree().create_timer(0.4,false).timeout
	warn(200,40,100,180,0.5)
	await get_tree().create_timer(0.5,false).timeout
	for i in 20:
		summonbones(5+i*10,200,0,0,40,180)
	await get_tree().create_timer(0.5,false).timeout
	var tweenbox =get_tree().create_tween()
	tweenbox.tween_property(Box,"position:x",Box.position.x+220,10)
	for i in 6:
		if i % 2 ==0:
			summonbones(200,0,0,100,200,90,2)
		else:
			summonbones(0,0,0,100,200,270,1)
		summonbones(0,200,150,0,100,180)
		summonbones(200,200,-150,0,100,180)
		await get_tree().create_timer(1.8,false).timeout
	await get_tree().create_timer(0.4,false).timeout
	endattack()

func attack3():
	boxsize(300,140)
	await get_tree().create_timer(0.9,false).timeout
	attackdot2(4,2.7,300,140)
	direct("down")
	var perma = []
	for t in 2:
		for i in 7:
			perma.append(summonbones(290-i*10,0,0,0,140))
			await get_tree().create_timer(0.08,false).timeout
		await get_tree().create_timer(0.4,false).timeout
		for i in 7:
			var b = summonbones(0-i*10,140,250,0,null,180)
			b.setwave(50,"sine",4,10,i/3.0)
		for i in perma:
			i.fire(-200,0,140,1)
			await get_tree().create_timer(0.1,false).timeout
		perma = []
		
		for i in 7:
			perma.append(summonbones(10+i*10,0,0,0,140))
			await get_tree().create_timer(0.08,false).timeout
		await get_tree().create_timer(0.4,false).timeout
		for i in 7:
			var b = summonbones(300+i*10,140,-250,0,null,180)
			b.setwave(50,"sine",4,10,i/3.0)
		for i in perma:
			i.fire(200,0,140,2)
			await get_tree().create_timer(0.1,false).timeout
		perma = []
		
	await get_tree().create_timer(0.5,false).timeout
	setmode("red")
	await get_tree().create_timer(0.2,false).timeout
	for i in 100:
		summonbones(-i*10,140,100,0,50+Extra.sine(i,15,25),180).limit = 69
		summonbones(300+i*10,0,-100,0,50+Extra.sine(i,15,25,5)).limit = 69
	for i in 10:
		summonbones(0,140,200,0,140,180,2).limit = 69
		await get_tree().create_timer(1,false).timeout
	await get_tree().create_timer(2,false).timeout
	endattack()

func attack4d2(n,h=25.0):
	for i in n:
		summonbones(-10,100,250,0,h,171).time = 0.01
		summonbones(260,0,-250,0,h,9).time = 0.01
		await get_tree().create_timer(0.08,false).timeout
func attack4():
	boxsize(250,100)
	await get_tree().create_timer(1,false).timeout
	attack4d2(269)
	attackdot2(5,3)
	for i in 3:
		await get_tree().create_timer(1,false).timeout
		for t in 3:
			summonbones(0,75,170,0,28,180)
			summonbones(-60,25,170,0,28)
			await get_tree().create_timer(0.7,false).timeout
		$warning.play()
		await get_tree().create_timer(0.25,false).timeout
		summonbones(250,25,-200,0,60,0,1).time = 0.01
		await get_tree().create_timer(0.6,false).timeout
		summonbones(0,25,200,0,60).time = 0.01
		await get_tree().create_timer(0.5,false).timeout
		var bl = summonbones(-20,8,0,0,268,270,1)
		for t in 2:
			summonbones(0,75,140,0,28,180)
			summonbones(250,25,-140,0,28)
			await get_tree().create_timer(0.7,false).timeout
		woosh.play()
		bl.fire(0,150)
		await get_tree().create_timer(0.7,false).timeout
		var b = summonbones(0,0,70,0,100)
		b.setwave(69,"sine",2,20)
		await get_tree().create_timer(1,false).timeout
	endattack()
	
func attack6d2(a):
	for i in 10:
		if a %2 ==0:
			summonbonesexternal(-Box.position.x,-Box.position.y,500,0,600-i,0,1).time = 0.9
		else:
			summonbonesexternal(640-Box.position.x,-Box.position.y,-500,0,600-i,0,1).time =0.9
		await get_tree().create_timer(0.07,false).timeout
func attack6():
	boxsize(200,200,0,0,0.4)
	await get_tree().create_timer(1,false).timeout
	attackdot2(3,2.7,200,200)
	for a in 4:
		for i in allbones.get_children():
			if i.tag == "dienext":
				i.queue_free()
		var playerpos = Player.position - Box.position
		warnmark(playerpos.x,playerpos.y,0.8)
		await get_tree().create_timer(0.2,false).timeout
		var playerpos2 = Player.position - Box.position
		warnmark(playerpos2.x,playerpos2.y,0.5)
		await get_tree().create_timer(0.5,false).timeout
		attack6d2(a)
		for i in 3:
			var b =summonbones(playerpos.x-(i+1)*10,0,0,0,200)
			b.time = 0.4
			b.tag = "dienext"
			await get_tree().create_timer(0.06,false).timeout
		woosh.play()
		await get_tree().create_timer(0.1,false).timeout
		for i in 3:
			var b = summonbones(200,playerpos2.y+(i-1)*10,0,0,200,90)
			b.time = 0.4
			b.tag = "dienext"
			await get_tree().create_timer(0.06,false).timeout
		woosh.play()
		
		$eyeflash.play()
		await get_tree().create_timer(0.4,false).timeout
		for i in allbones.get_children():
			if i.tag == "dienext":
				i.fire(0,0,0)
		await get_tree().create_timer(0.35,false).timeout
	for i in allbones.get_children():
		i.fire(0,0,0)
	await get_tree().create_timer(0.6,false).timeout
	boxsize(100,140)
	direct("down")
	await get_tree().create_timer(1,false).timeout
	for i in 6:
		var rh = randi_range(0,5)
		var bones= []
		bones.append(summonbones(10,140,0,0,35+rh*6,180))
		bones.append(summonbones(10,0,0,0,90-rh*6))
		
		await get_tree().create_timer(0.35,false).timeout
		rh = randi_range(0,5)
		var bones2= []
		bones2.append(summonbones(90,140,0,0,35+rh*6,180))
		bones2.append(summonbones(90,0,0,0,90-rh*6))
		
		await get_tree().create_timer(0.1,false).timeout
		for b in bones:
			weesh.play()
			b.fire(100)
			
		await get_tree().create_timer(0.75,false).timeout
		for b in bones2:
			weesh.play()
			b.fire(-100)
		await get_tree().create_timer(0.5,false).timeout
	await get_tree().create_timer(1,false).timeout
	endattack()

func attack5loopbone(time:float,size:float = 50):
	for i in time*15.0:
		summonbones(0,-10,0,300,size+i/4.0,270).time = 0.02
		summonbones(Box.size.x,-10,0,300,size+i/4.0,90).time = 0.02
		await get_tree().create_timer(0.07,false).timeout
		
func attack5():
	boxsize(300,500,0,80)
	await get_tree().create_timer(0.8,false).timeout
	throw("down")
	var plat = summonplatform(320,0,150,440)
	await get_tree().create_timer(0.8,false).timeout
	attack5loopbone(22,40)
	warn(300,80,150,500,0.5)
	await get_tree().create_timer(0.5,false).timeout
	var bottom= []
	for i in 30:
		bottom.append(summonbones(i*10,500,0,0,40,180))
	for i in 5:
		for r in 7:
			if i %2 ==0:
				summonplatform(0,0,-20-r*80,380-i*50,"pink",50).update(100,0)
			else:
				summonplatform(640,0,320+r*80,380-i*50,"pink",50).update(-100,0)
		await get_tree().create_timer(1.75,false).timeout
		for r in 3:
			await get_tree().create_timer(0.35,false).timeout
			summonbones(0-r*50,Box.size.y,150-r*5,0,155-r*3,180)
			summonbones(300+r*50,Box.size.y,-150+r*5,0,155-r*3,180)
			summonbones(0-r*50,0,150-r*5,0,320-r*3-i*50,0)
			summonbones(300+r*50,0,-150+r*5,0,320-r*3-i*50,0)
		var tw = get_tree().create_tween()
		tw.tween_property(Box,"size:y",Box.size.y-50,4)
		for b in bottom:
			var tw2 = get_tree().create_tween()
			tw2.tween_property(b,"position:y",b.position.y-50,4)
		await get_tree().create_timer(2.2,false).timeout
	await get_tree().create_timer(0.5,false).timeout
	for b in bottom:
		b.fire(0,400)
	await get_tree().create_timer(2,false).timeout
	boxsize(100,100,0,-150)
	setmode("red")
	await get_tree().create_timer(1.1,false).timeout
	var randomsequence = []
	var rsbone = []
	for i in 6:
		randomsequence.append(randi_range(1,2))
	for i in randomsequence.size():
		rsbone.append(summonbonesexternal(-20-i*20,200,0,0,200,180,randomsequence[i]))
		await get_tree().create_timer(0.15,false).timeout
		$eyeflash.play()
	await get_tree().create_timer(0.7,false).timeout
	for i in rsbone:
		var tw = get_tree().create_tween()
		tw.tween_property(i,"position:y",-200,0.2)
		await get_tree().create_timer(0.08,false).timeout
	for i in randomsequence.size():
		weesh.play()
		for b in 8:
			summonbonesexternal(-45,-200-b*10,0,600,200,270,randomsequence[i]).time = 0.01
		await get_tree().create_timer(0.8,false).timeout
	endattack()

func attack7():
	direct("down")
	boxsize(400,150)
	await get_tree().create_timer(1,false).timeout
	warn(400,50,200,140,1)
	for i in 2:
		summonplatform(540,350,400+i*130,100).update(-120,0)
	await get_tree().create_timer(1,false).timeout
	for i in 40:
		summonbones(i*10,150,0,0,30,180)
	await get_tree().create_timer(0.5,false).timeout
	for i in 24:
		await get_tree().create_timer(0.1,false).timeout
		summonplatform(640,350,450,100).update(-120,0)
		if i % 8 == 0:
			for b in 3:
				summonbones(-b*10,150,100,0,150,180).time = 0.01
			for b in 3:
				var d = summonbones(540+b*10,150,-170,0,70,180)
				d.setwave(70,"sine",4,10,b/3.0)
		await get_tree().create_timer(0.8,false).timeout
		if i % 8 == 0:
			summonbones(-50,150,140,0,150,180,2)
			for b in 5:
				var d = summonbones(-170-b*10,150,80,0,70,180)
				d.setwave(60,"triangle",3,20,b/3.0)
			for b in 3:
				var d2 = summonbones(500+b*10,-100,80,0,70,180)
				d2.setwave(69,"sine",3,15,b/3.0)
			summonbones(-450,0,150,0,80).limit= 69
			summonbones(-200,0,120,0,140,0,1)
	await get_tree().create_timer(1,false).timeout
	for i in allbones.get_children():
		i.fire(0,350)
	throw("down")
	await get_tree().create_timer(0.4,false).timeout
	boxsize(100,480,0,80)
	await get_tree().create_timer(1.4,false).timeout
	for i in 6:
		var r = randi_range(0,2)
		var bones = []
		for b in 9:
			bones.append(summonbones(-10,400-i*70,0,0,20))
			var tw = get_tree().create_tween()
			tw.tween_property(bones[b],"position:x",5+b*10,0.4)
			await get_tree().create_timer(0.03,false).timeout
		for b in 3:
			bones[b+r*3].fire(0,0,20+i*3,1)
			$eyeflash.play()
		await get_tree().create_timer(0.05,false).timeout
	var tw = get_tree().create_tween()
	tw.tween_property(Box,"size:y",40,5)
	await tw.finished
	endattack()

func MemoryModulate(m=0,t=0.5):
	var tw = get_tree().create_tween()
	tw.tween_property(Memory,"modulate:a",m,t)
func coolmemory():
	Modulate.color = memorycol
	for i in 4:
		Camera.glitch(0.5)
		Camera.blind(0.5)
		Camera.blur(0.5,0.6)
		await get_tree().create_timer(0.5,false).timeout
		Player.iframes = 100
		Camera.unblind(0.2)
		Camera.unglitch(0.2)
		Camera.blur(0.2,0)
		var tw = get_tree().create_tween()
		tw.tween_property(Camera.vignette,"modulate:a",1,0.1)
		MemoryModulate(1,0.1)
		Memory.frame = i
		await get_tree().create_timer(1.45,false).timeout
		Camera.glitch(0.1)
		Camera.blur(0.4)
		Camera.blinder.modulate.a = 0.5
		Modulate.color = Color.DARK_MAGENTA
		await get_tree().create_timer(0.5,false).timeout
		tw = get_tree().create_tween()
		tw.tween_property(Camera.vignette,"modulate:a",0.5,0.1)
		Camera.unblur(0.2)
		Modulate.color = defcol
		Camera.unblind(0.2)
		Camera.unglitch(0.2)
		MemoryModulate(0,0.2)
		await get_tree().create_timer(1.45,false).timeout
		
func fk2():
	var tw = get_tree().create_tween().set_loops(12)
	tw.tween_property(Boss.sprites,"position:x",Boss.sprites.position.x + randi_range(-10-(tw.get_loops_left())/5.0,10-(tw.get_loops_left())/5.0),0.04)
	tw.tween_interval(0.04)
func fakekill():
	Boss.head.frame = 2
	await get_tree().create_timer(0.5).timeout
	Boss.leftarm.frame = 3
	await get_tree().create_timer(0.2).timeout
	Boss.leftarm.frame = 2
	await get_tree().create_timer(0.7).timeout
	summonspike(Player.position.x,40,Player.position,500,2)
	await get_tree().create_timer(1.5).timeout
	fk2()
	Boss.head.frame = 3
	await get_tree().create_timer(0.5).timeout
	Boss.leftarm.frame = 3
	await get_tree().create_timer(0.2).timeout
	Boss.leftarm.frame = 0
func attackfinal():
	fakekill()
	Boss.musB.stop()
	Boss.musE.play()
	Camera.vignette.show()
	Camera.vignette.modulate.a = 0
	boxsize(64,32,0,0,1)
	var tw = get_tree().create_tween()
	tw.tween_property(Camera.vignette,"modulate:a",0.2,4.6)
	await tw.finished
	Camera.blind(0.4)
	Camera.glitch(0.5)
	await Camera.faded
	boxsize(350,150,0,0,0.25)
	Camera.unblind(0.5)
	Camera.unglitch(0.5)
	direct("down")
	var bonesend = []
	await get_tree().create_timer(0.5,false).timeout
	for i in 50:
		if i % 3 ==0&& i < 39:
			bonesend.append(summonbones(340-i*7.5,0,0,0,150))
			bonesend[i/3].trans = Tween.TRANS_BOUNCE
			await get_tree().create_timer(bonesend[i/3].time,false).timeout
			
		if i < 10 && i%3 == 0:
			summonbones(-60,150,200,0,150,180,1)
			summonbones(0,150,200,0,40,180)
			summonbones(350,0,-190,0,120)
			await get_tree().create_timer(0.08,false).timeout
		if i == 25:
			var t = get_tree().create_tween()
			t.tween_property(Box,"position:x",Box.position.x - 100,5).set_trans(Tween.TRANS_CIRC)
		if i > 11 && i < 17:
			summonbones(0,150,200,0,40,180)
			summonbones(0,0,200,0,90)
		if i > 20 && i < 30:
			summonbones(350,150,-270,0,40,180)
			summonbones(350,0,-270,0,95)
		if i > 27 && i < 32:
			summonbones(350,150,-250,0,25,180)
			summonbones(400,150,-250,0,100,180,1)
		if i == 35:
			for b in 25:
				summonbones(350+b*10,0,-150,0,60-Extra.sine(b,32,30),0).limit = 69
				summonbones(350+b*10,150,-150,0,60+Extra.sine(b,32,30),180).limit = 69
		if i == 38:
			setmode("red")
			summonbones(360,0,-250,0,150,0,2)
			for b in bonesend.size():
				bonesend[b].fire(0,-200)
				await get_tree().create_timer(0.05+i/250.0,false).timeout
		if i == 42:
			var t = get_tree().create_tween()
			t.tween_property(Box,"position:x",Box.position.x + 150,3)
			t.tween_property(Box,"position:x",Box.position.x + 100,1.5)
			throw("right")
			await get_tree().create_timer(0.7,false).timeout
			direct("down")
			
		if i > 42:
			var bb = summonbones(-(i-42)*10,150,200,0,40,180)
			summonbones(-(i-42)*10,0,200,0,90)
			bb.time = 0.01
			bb.setwave(40,"triangle",2.5,20,(i-42)*0.1)
			await get_tree().create_timer(0.4,false).timeout
	await get_tree().create_timer(1.1,false).timeout
	coolmemory()
	await get_tree().create_timer(2.25,false).timeout
	Player.position = Vector2(400,310)
	summonbones(60,0,200,0,115).limit = 69
	summonbones(-60,0,200,0,115).limit = 69
	summonbones(0,150,200,0,35,180).limit = 69
	var b = []
	b.append(summonbones(340,0,0,0,100,0,1))
	await get_tree().create_timer(0.2,false).timeout
	b.append(summonbones(328,0,0,0,90,0,1))
	await get_tree().create_timer(1,false).timeout
	for i in b.size():
		b[i].fire(-300,0,150)
	weesh.play()
	await get_tree().create_timer(2.5,false).timeout
	Player.position = Vector2(450,310)
	for i in 7:
		summonbones(0-i*10,150,250,0,32+Extra.sine(i,12,20),180)
		summonbones(-250-i*10,150,250,0,40+Extra.triangle(i,24,36),180).limit = 69
	summonbones(-150,0,250,0,100)
	summonbones(-250,0,250,0,120,0,2)
	await get_tree().create_timer(4.2,false).timeout
	direct("up")
	Player.position = Vector2(320,300)
	summonbones(0,0,200,0,40)
	summonbones(450,0,-250,0,60).limit = 69
	await get_tree().create_timer(0.6,false).timeout
	setmode("red")
	summonbonesexternal(-25,-200,0,350,200,270)
	summonbonesexternal(375,400,0,-350,200,90)
	await get_tree().create_timer(3,false).timeout
	boxsize(100,100,0,0,0.1)
	Player.position = Vector2(320,310)
	await get_tree().create_timer(0.65,false).timeout
	throw("down")
	warnmark(320,380,0.5)
	await get_tree().create_timer(0.3,false).timeout
	b = []
	for i in 10:
		b.append(summonbones(i*10,100,0,0,0,180))
		b[i].time = 0.01
	await get_tree().create_timer(0.05,false).timeout
	for i in b.size():
		b[i].tweensize.kill()
		var t = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
		t.tween_property(b[i].bone,"size:y",40,0.25).set_delay(i/50.0)
		t.tween_property(b[i].bone,"size:y",0,0.25).set_delay(0.25)
	await get_tree().create_timer(0.6,false).timeout
	
	throw("right")
	warnmark(380,320,0.5)
	b = []
	await get_tree().create_timer(0.3,false).timeout
	for i in 10:
		b.append(summonbones(100,i*10,0,0,0,90))
		b[i].time = 0.01
	await get_tree().create_timer(0.05,false).timeout
	for i in b.size():
		b[i].tweensize.kill()
		var t = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
		t.tween_property(b[i].bone,"size:y",40,0.25).set_delay(i/50.0)
		t.tween_property(b[i].bone,"size:y",0,0.25).set_delay(0.25)
	await get_tree().create_timer(0.6,false).timeout
	
	throw("left")
	warnmark(260,320,0.5)
	warnmark(320,260,0.5)
	b = []
	var b2 = []
	await get_tree().create_timer(0.3,false).timeout
	for i in 10:
		b.append(summonbones(i*10,0,0,0,0))
		b[i].time = 0.01
		b2.append(summonbones(0,i*10,0,0,0,270))
		b2[i].time = 0.01
	await get_tree().create_timer(0.05,false).timeout
	for i in b.size():
		b[i].tweensize.kill()
		var t = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
		t.tween_property(b[i].bone,"size:y",40,0.25).set_delay(i/50.0)
		t.tween_property(b[i].bone,"size:y",0,0.25).set_delay(0.25)
	for i in b2.size():
		b2[i].tweensize.kill()
		var t = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
		t.tween_property(b2[i].bone,"size:y",40,0.25).set_delay(i/50.0)
		t.tween_property(b2[i].bone,"size:y",0,0.25).set_delay(0.25)
	summonbonesexternal(-25,-200,0,400,150,270,1).time = 0.01
	await get_tree().create_timer(0.5,false).timeout
	for i in allbones.get_children():
		i.queue_free()
	setmode("red")
	Box.changesizey(300,50,0.5)
	for i in 2:
		b = summonbones(50,-150,0,200,100)
		b.offset.y = -50
		var bt= get_tree().create_tween()
		bt.tween_property(b,"rotation_degrees",1800,9)
		await get_tree().create_timer(0.75,false).timeout
		b = summonbones(50,-150,0,200,100)
		b.offset.y = -50
		var bt2= get_tree().create_tween()
		bt2.tween_property(b,"rotation_degrees",-1800,9)
		await get_tree().create_timer(0.75,false).timeout
	await get_tree().create_timer(1,false).timeout
	Box.changesizex(350,0,0.4)
	Box.changesizey(200,50,0.4)
	await get_tree().create_timer(0.5,false).timeout
	for i in 70:
		if i % 10 == 0:
			summonbones(0,0,220,0,200,0,2)
		b = summonbones(0,0,150,0,75)
		b.limit = 69
		b.setwave(75,"sine",6,25,i/2.0)
		b = summonbones(0,200,150,0,75,180)
		b.limit = 69
		b.setwave(75,"sine",6,25,i/2.0)
		await get_tree().create_timer(0.12,false).timeout
	await get_tree().create_timer(0.7,false).timeout
	warnmark(320,380,0.5)
	await get_tree().create_timer(0.5,false).timeout
	direct("down")
	boxsize(200,150)
	await get_tree().create_timer(1,false).timeout
	for i in 2:
		summonbones(-i*12,150,250,0,32+i*15,180)
		summonbones(200+i*12,150,-250,0,32+i*15,180)
	summonbones(200,0,-300,0,140,180,1)
	castbullet(1,-400,150,350,0)
	await get_tree().create_timer(1.6,false).timeout
	for i in 2:
		summonbones(0,150,220,0,30,180)
		summonbones(0,0,220,0,100)
		await get_tree().create_timer(0.6,false).timeout
	await get_tree().create_timer(0.5,false).timeout
	throw("up")
	warn(200,100,100,100,0.4)
	await get_tree().create_timer(0.3,false).timeout
	for i in 20:
		b = summonbones(i*10,150,0,0,90,180)
		if i > 5 && i < 15:
			b.tag = "becomeblue"
	await get_tree().create_timer(0.2,false).timeout
	summonbones(0,0,140,0,30)
	await get_tree().create_timer(0.5,false).timeout
	summonbones(200,0,-360,0,20)
	warnmark(220,320,0.5)
	warnmark(420,320,0.5)
	await get_tree().create_timer(0.6,false).timeout
	for i in allbones.get_children():
		if i.tag == "becomeblue":
			i.fire(0,0,150,1)
	await get_tree().create_timer(0.6,false).timeout
	for i in allbones.get_children():
		if i.tag != "becomeblue":
			i.fire(0,0,150)
	await get_tree().create_timer(0.8,false).timeout
	Camera.blind(0.1)
	await get_tree().create_timer(0.1,false).timeout
	for i in allbones.get_children():
		i.queue_free()
	boxsize(300,100,-40,100,0.1)
	direct("down")
	await get_tree().create_timer(0.2,false).timeout
	Camera.unblind(0.1)
	Box.changesizex(300,80,4)
	for i in 5:
		summonbones(300+i*100,100,-200,0,30,180).limit = 69
		b = summonbones(300+i*100,0,-200,0,50)
		b.limit = 69
		b.tag = "rev"
	await get_tree().create_timer(1.5,false).timeout
	warnmark(-100,-100,0.2)
	castbullet(0,100,-200,250,0)
	for i in allbones.get_children():
		tw = get_tree().create_tween()
		tw.bind_node(i)
		tw.tween_property(i,"vel:x",0,0.6)
		if i.tag == "rev":
			tw.tween_callback(i.fire.bind(120,0,75)).set_delay(0.2)
		else:
			tw.tween_callback(i.fire.bind(-120,0,35)).set_delay(0.2)
	await get_tree().create_timer(2.25,false).timeout
	setmode("red")
	boxsize(300,100,-60,-100,0.25)
	await get_tree().create_timer(0.7,false).timeout
	Box.changesize(31,31,0,0.06)
	await get_tree().create_timer(0.15,false).timeout
	for i in 10:
		summonspike(randi_range(50,590),randi_range(20,100),Player.position,400,10).tag = "spike"
		await get_tree().create_timer(0.06,false).timeout
	Camera.blind(0.1)
	Camera.glitch(0.1)
	tw =get_tree().create_tween()
	tw.tween_property(Camera.vignette,"modulate:a",0.55,0.5)
	await get_tree().create_timer(0.1,false).timeout
	##||##
	var newsize = get_tree().create_tween()
	var newpos = get_tree().create_tween()
	newsize.tween_property(Box,"size:x",Box.defaltsize.x,0.05).set_trans(Box.type).set_ease(Box.type2)
	newsize.tween_property(Box,"size:y",Box.defaltsize.y,0.05).set_trans(Box.type).set_ease(Box.type2)
	newpos.tween_property(Box,"position:x",Box.defaultpos.x,0.05).set_trans(Box.type).set_ease(Box.type2)
	newpos.tween_property(Box,"position:y",Box.defaultpos.y,0.05).set_trans(Box.type).set_ease(Box.type2)
	##||##
	tw = get_tree().create_tween()
	tw.tween_property(Player,"position:x",-100,0.4).as_relative()
	await get_tree().create_timer(0.2,false).timeout
	Camera.unglitch(0.1)
	Player.mode = "nomove"
	disabledinput = true
	await get_tree().create_timer(0.5,false).timeout
	for i in externalbones.get_children():
		if i.tag == "spike":
			var t = get_tree().create_tween()
			t.set_parallel(true)
			t.tween_property(i,"position:y",400,1).as_relative()
			t.tween_property(i,"modulate:a",0,1)
			t.tween_property(i,"rotation",TAU,1)
			t.tween_callback(i.queue_free).set_delay(0.5)
	Camera.unblind(0.1)
	Fight.anim.play("slash")
	Fight.slash.show()
	await get_tree().create_timer(0.6,false).timeout
	Fight.damsH.play()
	Fight.hpbar.show()
	Fight.slash.frame = 6
	Fight.dmg.text = "640"
	Fight.dmg.modulate = Color.RED
	Fight.anim.play("move")
	Fight.endslash(640)
	Boss.head.frame = 4
	Boss.body.frame = 1
	await get_tree().create_timer(0.5,false).timeout
	finalcutscene()
	

