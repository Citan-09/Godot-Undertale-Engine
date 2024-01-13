extends Control
class_name  WhiteBox

var cancel = false
var typing = false
var text = FileAccess.open("res://Shared/Text/MenuText.json",FileAccess.READ)
var texts = JSON.parse_string(text.get_as_text())
var time = 0.1
@export var sizetime:float = 0.5
@export var type = Tween.TRANS_QUINT
@export var type2 = Tween.EASE_IN_OUT
@export var texture = load("res://Shared/Box/boxfancy.png")

var SelectedAction

var acts
var horizontal
var vertical

@export var margin = 4.0
@onready var defaltsize = self.size
@onready var defaultpos = self.position
var text1 = "*"
var text2 = "*                 *\n"

var encounter = "sans"
var noprogress = false
var choseChoice = false
var itempage = 1
var optamt = 1
var inpos = false
var soulpos = 0
var possiblepos = [
	Vector2(25,35),Vector2(305,35),
	Vector2(25,70),Vector2(305,70),
	Vector2(25,105),Vector2(305,105),
	]

@onready var Butn = get_node("/root/main/Camera2D/buttons")
@onready var Player = get_node("/root/main/soul")
@onready var Boss = get_node("/root/main/boss")
@onready var PutThings = $BoxContainer/NinePatchRect/PutThings
@onready var soul = $MenuSoul
@onready var squeak = $MenuSoul/Squeak
@onready var select = $MenuSoul/Select
@onready var Rect = $BoxContainer/NinePatchRect
@onready var blitter = $BoxContainer/NinePatchRect/Ast/Blitter
@onready var label1 = $BoxContainer/NinePatchRect/Ast/Label
@onready var label2 = $BoxContainer/NinePatchRect/Ast/Label2
@onready var label3 = $BoxContainer/NinePatchRect/Ast/Label3
@onready var Click= $BoxContainer/NinePatchRect/Ast/Noise
@onready var Collisions = $BoxContainer/NinePatchRect/Collisions
@onready var ast = $BoxContainer/NinePatchRect/Ast
@onready var container = $BoxContainer

signal fight

signal xdone
func changesize(x,y,modx = 0,mody = 0,sizetimet = sizetime):
	changesizex(x+margin,modx,sizetimet)
	await xdone
	changesizey(y+margin,mody,sizetimet)
func changesizex(x, modx=0, sizetimet=sizetime):
	var newsize = get_tree().create_tween()
	var newsize1 = get_tree().create_tween()
	newsize.tween_property(self,"size:x",x,sizetimet).set_trans(type).set_ease(type2)
	newsize1.tween_property(self,"position:x",position.x - modx-(x-self.size.x)/2,sizetimet).set_trans(type).set_ease(type2)
	await newsize1.finished
	emit_signal("xdone")
func changesizey(y, mody=0, sizetimet=sizetime):
	var newsize = get_tree().create_tween()
	var newsize1 = get_tree().create_tween()
	newsize.tween_property(self,"size:y",y,sizetimet).set_trans(type).set_ease(type2)
	newsize1.tween_property(self,"position:y",position.y - mody-(y-self.size.y)/2,sizetimet).set_trans(type).set_ease(type2)
# Called when the node enters the scene tree for the first time.
func _ready():
	if get_node("/root/main/soul")&&get_node("/root/main/soul").soultype == "monster":
		soul.scale.y = -1
		soul.modulate = Color.WHITE
	else:
		soul.scale.y = 1
		soul.modulate = Color.RED
	defaultpos= self.position
	Rect.texture = texture
	await get_tree().process_frame
	typetext(getDialogue("MenuText",0))
func getDialogue(choice: String,line = 1):
	var test:String
	if choice == "ItemText":
		test = texts[choice]
	else:
		test = texts[encounter][choice]
		
	test = test.replace("[matk]",str(Game.matk))
	test = test.replace("[mdef]",str(Game.mdef))
	test = test.replace("	","")
	test = test.split("\n")[line]
	test = test.replace("/n","\n")
	return test

func menulist(num):
	optamt = num
	var tempstr = ""
	if num % 2 == 1:
		for i in range(0,floor(num/2),1): 
			tempstr += text2
		tempstr += text1
		ast.text = tempstr
	elif num % 2 == 0: 
		for i in range(0,floor(num/2),1): 
			tempstr += text2
		ast.text = tempstr
func writeoptions1arg(array): #SPLIT BY "\n"
	label1.text = ""
	label2.text = ""
	var asize = array.size()
	for i in asize:
		if i %2 ==0:
			label1.text += array[i] + "\n"
		else:
			label2.text += array[i] + "\n"

func writeoptions(o1 = "",o2 = "",o3 = "",o4 = "",o5 = "",o6 = ""):
	label1.text = o1 + "\n" 
	label2.text = o2 + "\n" 
	label1.text += o3 + "\n" 
	label2.text += o4 + "\n" 
	label1.text += o5 + "\n"
	label2.text += o6 + "\n"

#await get_tree().create_timer(time).timeout
func returntomenu():
	var newsize = get_tree().create_tween()
	var newpos = get_tree().create_tween()
	newsize.tween_property(self,"size:x",defaltsize.x,sizetime/2.0).set_trans(type).set_ease(type2)
	newsize.tween_property(self,"size:y",defaltsize.y,sizetime/2.0).set_trans(type).set_ease(type2)
	newpos.tween_property(self,"position:x",defaultpos.x,sizetime/2.0).set_trans(type).set_ease(type2)
	newpos.tween_property(self,"position:y",defaultpos.y,sizetime/2.0).set_trans(type).set_ease(type2)
	await newsize.finished
	getturn()
func getturn():
	cancel = false
	ast.visible = true
	Butn.movesoul(0)
	blitter.show()
	typetext(getDialogue("MenuText",Boss.attacknum))
	Butn.enable()
	
func leavemenu():
	ast.visible = false
	cleartxt()
func _unhandled_input(event):
	if choseChoice && event.is_action("Confirm") && !typing:
		if !noprogress:
			cancel = false
			choseChoice = false
			Boss.dialogue()
			leavemenu()
			##END TURN
		else:
			noprogress = false
			cancel = false
			choseChoice = false
			Boss.attacknum -=1
			leavemenu()
			Boss.emit_signal("attack",32767) #this is healing attack
	if event.is_action_pressed("slow_down") &&typing:
		cancel = true
		
	#Choise selecton
	if inpos:
		if event.is_action_pressed("slow_down"):
			inpos = false
			cleartxt()
			menulist(1)
			blitter.visible_characters = -1
			blitter.show()
			typetext(getDialogue("MenuText",Boss.attacknum))
			Butn.enable()
			Butn.movesoul(0)
		if event.is_action_pressed("Confirm"):
			inpos = false
			cleartxt()
			select.play()
			if SelectedAction:
				choseChoice = true
			match SelectedAction:
				0:
					cancel = true
					cleartxt()
					emit_signal("fight")
				1:
					menulist(acts.size())
					writeoptions1arg(acts)
					inpos = true
					choseChoice = false
					noprogress = true
					SelectedAction = 4
				2:
					blitter.show()
					typetext(getDialogue("ItemText",Data.items[soulpos]-1))
					noprogress = true
					Player.heal(Data.UseItem(soulpos))
				3:
					noprogress = true
					blitter.show()
					typetext(getDialogue("SpareText",soulpos))
				4:
					blitter.show()
					typetext(getDialogue("ActText",soulpos))
					
		if event.is_action_pressed("ui_right"):
			if soulpos % 2 ==0 && soulpos < optamt-1:
				squeak.play()
				soulpos += 1
		if event.is_action_pressed("ui_left"):
			if soulpos % 2 != 0:
				squeak.play()
				soulpos -= 1
		if event.is_action_pressed("ui_down"):
			if soulpos < optamt - 2:
				squeak.play()
				soulpos += 2
			else:
				if SelectedAction == 2:
					var i = Data.returnItemArray(soulpos+4).split("\n")
					#writeoptions(i[0],i[1],i[2],i[3],"","2/2 (↑)")
					writeoptions1arg(i)
					menulist(i.size()-1)
					label3.text = "Page 1: (↑)"
					itempage = 2
					
		if event.is_action_pressed("ui_up"):
			if soulpos > 1:
				squeak.play()
				soulpos -= 2
			else:
				if SelectedAction == 2:
					var i:PackedStringArray = Data.returnItemArray(soulpos-4).split("\n")
					#writeoptions(i[0],i[1],i[2],i[3],"","1/2 (↓)")
					writeoptions1arg(i)
					menulist(i.size()-1)
					if Data.items.size() > 4:
						label3.text = "Page 2: (↓)"
					itempage = 1
			
func _process(delta):
	container.size = self.size
	PutThings.size = container.size - Vector2(margin,margin)
	self.pivot_offset = self.size/2
	Collisions.get_child(0).position = Vector2(container.size.x/2,-346+margin)
	Collisions.get_child(1).position = Vector2(container.size.x+348-margin,container.size.y/2)
	Collisions.get_child(2).position = Vector2(container.size.x/2,container.size.y+348-margin)
	Collisions.get_child(3).position = Vector2(-346+margin,container.size.y/2)
	
	#SIZE
	Collisions.get_child(0).shape.size = Vector2(2*container.size.x,702)
	Collisions.get_child(1).shape.size = Vector2(702,2*container.size.y)
	Collisions.get_child(2).shape.size = Vector2(2*container.size.x,702)
	Collisions.get_child(3).shape.size = Vector2(702,2*container.size.y)
	$ColorRect.size = container.size
	if inpos:
		soul.show()
		menumove()
		ast.position.x = 40
	else:
		soul.hide()
		ast.position.x = 16
	if inpos or !ast.visible:
		blitter.hide()
		
func menumove():
	if soulpos>=optamt:
		soulpos-=1
	soul.position = possiblepos[soulpos]
	
	
func cleartxt():
	menulist(0)
	label1.text = ""
	label2.text = ""
	label3.text = ""
func typetext(text:String):
	cancel = false
	var regex = RegEx.new()
	regex.compile("([.,!?])")
	blitter.visible_characters = 0
	typing = true
	menulist(1)
	var temptext = text.split()
	blitter.text = text
	for i in text.length():
		if cancel:
			cancel = false
			typing = false
			blitter.visible_characters = -1
			return
		blitter.visible_characters += 1
		if !regex.search(temptext[i]):
			await get_tree().create_timer(time/5.0).timeout
			Click.play()
		else:
			await get_tree().create_timer(time).timeout
		if temptext[i] == " ":
			await get_tree().create_timer(time/5.0).timeout
	typing = false

func putattack(obj:Object,parent:Object,unput= false):
	if !unput:
		parent.remove_child(obj)
		PutThings.add_child(obj)
	else:
		PutThings.remove_child(obj)
		parent.add_child(obj)
		
	
