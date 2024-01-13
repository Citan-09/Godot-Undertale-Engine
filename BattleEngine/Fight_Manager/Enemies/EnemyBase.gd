extends Node2D
class_name Enemy
const time = 0.1
@onready var noise = $Speech/SpeechSound
@onready var speech :RichTextLabel= $Speech/RichTextLabel
@onready var speechfull = $Speech
@onready var cam = get_node("/root/main/Camera2D")
@onready var head = $Sprites/Upper2/Head
@onready var attacks = get_node("/root/main/attacks")
@onready var fight =  get_node("/root/main/box/fight")
var file = FileAccess.open("res://Shared/Text/EnemySpeechList.json",FileAccess.READ)
@export var Name = "sans"
var current : int = 0
var attacknum : int = 0
var killmessage = false
var typing = false

signal attack
signal finishspeech
var speechlist
var dodging = false
# Called when the node enters the scene tree for the first time.
func _ready():
	idleanim()
	speechfull.hide()
	
	init()
	initdialogue()
func initdialogue():
	speechlist = JSON.parse_string(file.get_as_text())[Name]
func init():
	pass
	
func dodge():
	pass
var splitter = "|S|"
func speak(startline=0,endline=1):
	var texttotal:PackedStringArray = []
	for i in endline-startline+1:
			texttotal.append(speechlist[startline+i] if speechlist.size() >= startline+i else "0Missing at line %s" % [startline+i])
	typetext(texttotal)
		

func mute():
	pass
@onready var sprites = $Sprites
@onready var body = $Sprites/Upper/Body

func dialogue():
	pass

func throwanim(dir):
	await get_tree().process_frame
	emit_signal("finishthrow")

signal finishthrow
signal finish
signal confirm
func _unhandled_input(event: InputEvent) -> void:
	sprites.move_and_slide()
	if event.is_action_pressed("Confirm") && speechfull.visible:
		emit_signal("confirm")
	if event.is_action_pressed("slow_down") &&typing:
		killmessage = true
func _process(delta: float) -> void:
	tick(delta)
func tick(delta):
	pass
func writefor(text,chartext,regex):
	typing = true
	for i in speech.get_total_character_count():
		speech.visible_characters = i+1
		if !regex.search(chartext[i]):
			await get_tree().create_timer(time/5.0,false).timeout
			noise.play()
		else:
			await get_tree().create_timer(time,false).timeout
		if chartext[i] == " ":
			await get_tree().create_timer(time/5.0,false).timeout
		if killmessage:
			speech.visible_characters = -1
			emit_signal("finish")
			killmessage = false
			return
	emit_signal("finish")
	typing = false
	return
func typetext(alltext: PackedStringArray):
	speechfull.show()
	var regex = RegEx.new()
	regex.compile("([.,!?])")
	var num = alltext.size()
	for d in num:
		var ctext = alltext[d]
		var result
		var chartext = ctext.split()
		speech.visible_characters = 0
		#HEADS MANAGER
		var firstchar = ctext.left(ctext.length()-1)
		head.frame = int(firstchar)
		ctext = ctext.substr(1)
		speech.text = ctext
		writefor(ctext,chartext,regex)
		await finish
		await confirm
		
	typing = false
	
	speech.text = ""
	killmessage = true
	speechfull.hide()
	emit_signal("attack",attacknum)
	
	
func idleanim():
	pass

signal hurtfinish
func hurtanim():
	var pos = sprites.position
	for i in 10:
		sprites.position.x = pos.x+ randf_range(-5,5)
		await get_tree().create_timer(0.06,false).timeout
	sprites.position = pos
func damaged(damage):
	if damage >0:
		hurtanim()
	await get_tree().create_timer(1.8,false).timeout
	dialogue()
func hurt():
	pass

