extends CanvasLayer
var cancel = false
var typing
@onready var blitter = $Control/MarginContainer/NinePatchRect/Label/Text
@export var time = 0.1
var sound

@export var SummonSpeed = 0.4
@export var HeadSpeed = 0.2
@onready var head = $Control/Control/MarginContainer2/HeadRect/AnimatedSprite2D
@onready var defpos = $Control/MarginContainer/NinePatchRect/Label.position
@onready var ast = $Control/MarginContainer/NinePatchRect/Label
@onready var defsize = blitter.size

@export var Fonts = [] #0 DTM 1 PAPYRUS 2 SANS
## Put this in the Dialogue right before the battle
@export var battlesignal = "⚔️"
var currentcharacter
var speechdata = FileAccess.open("res://Shared/Text/OverworldDialogue.json",FileAccess.READ)
var speeches = JSON.parse_string(speechdata.get_as_text())
signal done
signal holdbattle
signal togglemove
signal confirm
signal finish
var boxissummon = false

func selectsound(h = 0):
	blitter.add_theme_font_override("normal_font",load(Fonts[0]))
	match currentcharacter:
		null:
			sound = $Control/MarginContainer/NinePatchRect/Sounds/Generic
		"sans":
			sound = $Control/MarginContainer/NinePatchRect/Sounds/Sans
			blitter.add_theme_font_override("normal_font",load(Fonts[2]))
		"snowdin":
			if h > 3:
				blitter.add_theme_font_override("normal_font",load(Fonts[2]))
				sound = $Control/MarginContainer/NinePatchRect/Sounds/Sans
			else:
				blitter.add_theme_font_override("normal_font",load(Fonts[1]))
				sound = $Control/MarginContainer/NinePatchRect/Sounds/Papyrus
func _ready():
	$Control.modulate.a = 0
	head.modulate.a = 0
	$Control.size.x = 0
	#$Control.position.y += 200
	ast.hide()
	#DEBUG:
	#$Control/MarginContainer.summon(Vector2(320,240)*$Control/MarginContainer.scale,"sansintro","sans")
	
func summon(campos:Vector2,speech:String,character = null):
	if boxissummon:
		return
	boxissummon = true
	blitter.text = ''
	currentcharacter = character
	emit_signal("togglemove",false)
	var t = get_tree().create_tween()
	t.tween_property($Control,"size:x",585,SummonSpeed).set_trans(Tween.TRANS_QUART)
	var t2 = get_tree().create_tween()
	t2.tween_property($Control,"modulate:a",1,SummonSpeed).set_trans(Tween.TRANS_QUART)
	var hashead = false
	if character:
		head.show()
		#ast.position = defpos + Vector2(110,0)
		#blitter.size = defsize - Vector2(200,0)
		$Control/Control.show()
		var t3 = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC)
		t3.tween_property(head,"modulate:a",1,HeadSpeed)
		head.animation = str(character)
		hashead = true
	else:
		$Control/Control.hide()
		head.hide()
		ast.position = defpos
		blitter.size = defsize
	await t.finished
	#typetexts
	ast.show()
	typetext(speeches[speech],hashead)
	await done
	hidetextbox()
	
func hidetextbox():
	var t = get_tree().create_tween()
	t.tween_property($Control,"size:x",0,SummonSpeed).set_trans(Tween.TRANS_QUART)
	var t2 = get_tree().create_tween()
	t2.tween_property($Control,"modulate:a",0,SummonSpeed).set_trans(Tween.TRANS_QUART)
	emit_signal("togglemove",true)
	boxissummon = false
	if currentcharacter:
		var t3 = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC)
		t3.tween_property(head,"modulate:a",0,HeadSpeed)
	await t.finished
	ast.hide()
	
	#$Control/MarginContainer.position.y += 100

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("Confirm"):
		emit_signal("confirm")
	if Input.is_action_just_pressed("slow_down") && typing:
		cancel = true
	##DEBUG##

var uncancelable = false
func typeit(text:String,chartext,regex):
	typing = true
	var char1 = chartext[0]
	if char1== battlesignal:
		blitter.text = text.substr(1)
		uncancelable = true
	for i in blitter.get_total_character_count():
		blitter.visible_characters = i+1
		if !regex.search(chartext[i]):
			await get_tree().create_timer(time/5.0).timeout
			sound.play()
		else:
			await get_tree().create_timer(time).timeout
		match chartext[i]:
			" ":
				await get_tree().create_timer(time/5.0).timeout
		
		if cancel && !uncancelable:
			cancel = false
			typing = false
			blitter.visible_characters = -1
			emit_signal("finish")
			return
	typing = false
	emit_signal("finish")
	if uncancelable:
		emit_signal("holdbattle")
	return
func typetext(Alltext:String,hashead = false):
	var txtarray = Alltext.replace("	","").replace("\n","NLN|N").replace("/n","\n").split("NLN|N")
	for t in txtarray.size():
		blitter.visible_characters = 1
		var text = txtarray[t]
		var regex = RegEx.new()
		regex.compile("([.,!?])")
		if hashead:
			var firstchar = text.left(text.length()-1)
			head.frame = int(firstchar)
			selectsound(int(firstchar))
			text = text.substr(1)
		else:
			selectsound()
		var chartext = text.split()
		blitter.text = text
		typeit(text,chartext,regex)
		await finish
		await confirm
	emit_signal("done")
