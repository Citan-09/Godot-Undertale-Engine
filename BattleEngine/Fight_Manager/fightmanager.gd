extends Node2D
class_name Fightmanager

#var EnemyName = "NoName"

var blastercolor = Color("ffffff")
var bonecolor = Color("ffffff")
@onready var platform = preload("res://Shared/misc/platform.tscn")
@onready var bone = preload("res://BattleEngine/Fight_Manager/Enemies/bone.tscn")
@onready var blaster = preload("res://BattleEngine/Fight_Manager/Enemies/blaster.tscn")
@onready var warning = preload("res://BattleEngine/gui/warning.tscn")
@onready var warning2 = preload("res://BattleEngine/gui/warning2.tscn")
@onready var bg = get_node("/root/main/Background")
@onready var Camera:Camera2DVFX = get_node("/root/main/Camera2D")
@onready var Blinder = get_node("/root/main/Camera2D/ColorRect")
@onready var Box :WhiteBox= get_node("/root/main/box")
@onready var Butn = get_node("/root/main/Camera2D/buttons")
@onready var Fight = get_node("/root/main/box/fight")
@onready var Boss:Enemy = get_node("/root/main/boss")
@onready var Player = get_node("/root/main/soul")
@onready var allbones = get_node("/root/main/box/BoxContainer/NinePatchRect/PutThings/Bones")
@onready var allnotbones = get_node("/root/main/box/BoxContainer/NinePatchRect/PutThings/NonBones")
@onready var attacks = get_node("/root/main/box/BoxContainer/NinePatchRect/PutThings")
@onready var vfx = get_node("/root/main/vfx")
var fighting = false
var currentattack = 0
var heart = preload("res://Shared/Soul/soul.tscn")


func warn(x,y,modx,mody,time,rot = 0):
	var clone = warning.instantiate()
	allnotbones.add_child(clone)
	clone.summonwarn(x,y,modx,mody,time,rot)
	
func warnmark(posx,posy,time):
	var clone = warning2.instantiate()
	allnotbones.add_child(clone)
	clone.summonwarn(posx,posy,time)


func setmode(col:String):
	Player.setmode(col)

func boxsize(x,y,mx= 0,my= 0,t = Box.sizetime):
	Box.changesize(x,y,mx,my,t)
	
func throw(dir):
	Boss.throwanim(dir)
	await Boss.finishthrow
	Player.throw(dir)
	
func direct(dir):
	Player.mode = "blue"
	Player.changedir(dir)
# Called when the node enters the scene tree for the first time.
func doattack(turn):
	Player.intobattle()
	switchattack(turn)
	Boss.attacknum+= 1
func _ready():
	Player.hide()
	Box.fight.connect(Fight.start)
	Butn.select.connect(usebutton)
	Boss.attack.connect(doattack)
	Player.predeath.connect(predeath)
	Blinder.modulate.a = 1
	init()
	Camera.unblind(0.6)
	acts =  (JSON.parse_string(MenuTexts.get_as_text())[Box.encounter]["ActOptions"]).replace("	","").split("\n")
	
func predeath():
	if vfx:
		vfx.hide()
	get_node("/root/main/attacks").queue_free()
	allbones.queue_free()
	Boss.mute()
func switchattack(turnnum = 0):
	pass
func init():
	pass

var MenuTexts = FileAccess.open("res://Shared/Text/MenuText.json",FileAccess.READ)
var acts :PackedStringArray

func usebutton(choice):
	Box.acts = acts
	Box.cleartxt()
	Box.cancel = true
	match choice:
		0:
			Box.SelectedAction = 0
			Box.menulist(1)
			Box.writeoptions(Game.mname)
			Box.inpos = true
		1:
			Box.blitter.show()
			Box.SelectedAction = 1
			Box.menulist(1)
			Box.writeoptions(Game.mname)
			Box.inpos = true
		2:
			if Data.items.size() ==0:
				Box.menulist(1)
				Box.blitter.show()
				Butn.enable()
				return
			Box.blitter.show()
			Box.SelectedAction = 2
			var i = Data.returnItemArray(0).split("\n")
			#i.resize(4)
			#Box.writeoptions(i[0],i[1],i[2],i[3],"","1/2 (↓)")
			Box.menulist(i.size()-1)
			Box.writeoptions1arg(i)
			if Data.items.size() > 4:
				Box.label3.text = "Page 2: (↓)"
			Box.inpos = true
		3:
			Box.blitter.show()
			Box.SelectedAction = 3
			Box.menulist(1)
			Box.writeoptions(Game.mname)
			Box.inpos = true



func endattack():
	Box.returntomenu()
	setmode("cutscene")
	Player.velocity = Vector2.ZERO
	for i in allbones.get_children()+allnotbones.get_children():
		i.queue_free()
	await get_tree().create_timer(Box.sizetime,false).timeout
	Player.intomenu(Butn.get_child(0).global_position- Vector2(38,0))

func custombonecolor(clone):
	clone.modulate = bonecolor
func customblastercolor(clone):
	clone.beam.modulate = blastercolor
	clone.blaster.modulate = blastercolor
func summonbones(posx= 0,posy = 420,velx = 300,vely= 0,size = 90,Rotation = 0,mode = 0,endx = null):
	var clone = bone.instantiate()
	#Box.putattack(clone)
	allbones.add_child(clone)
	clone.fire(velx,vely,size,mode,Rotation,endx)
	custombonecolor(clone)
	clone.position = Vector2(posx, posy) #+ Box.Rect.global_position
	return clone
func summonblaster(posx= 0,posy=0,rot=null,width=null,delay = 1,color = 0):
	var clone = blaster.instantiate()
	add_child(clone)
	if posx != null:
		clone.fire(posx,posy,rot,width,delay,color)
	customblastercolor(clone)
	return clone
func summonplatform(posx =0,posy=0,tx=0,ty=0,color="green",length = 60):
	var clone = platform.instantiate()
	allnotbones.add_child(clone)
	clone.cast(posx,posy,tx,ty,color,length)
	return clone
