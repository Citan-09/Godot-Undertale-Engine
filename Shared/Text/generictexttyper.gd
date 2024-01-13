extends Node
class_name TextTyperGeneric

var uncancelable
var sound
var time = 0.1
var nocancel = "☆"
var Textlabel:RichTextLabel
var typing = false
var cancel = false

signal done
signal finish 
signal confirm

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Confirm"):
		emit_signal("confirm")
	if event.is_action_pressed("slow_down"):
		cancel = true
func typeit(text:String):
	var regex = RegEx.new()
	regex.compile("([.,!?])")
	Textlabel.text = text
	var chartext = Textlabel.get_parsed_text().split()
	var char1 = chartext[0]
	if char1== nocancel:
		Textlabel.text = text.substr(1)
		uncancelable = true
	for i in Textlabel.get_total_character_count():
		Textlabel.visible_characters = i+1
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
			Textlabel.visible_characters = -1
			emit_signal("finish")
			return
	typing = false
	emit_signal("finish")
	if uncancelable:
		emit_signal("holdbattle")
	return
func typetext(Alltext:String,split = false):
	if split:
		repeattext(splitline(Alltext))
	else:
		repeattext([Alltext])

func repeattext(txtarray:Array):
	var max = txtarray.size()
	for t in max:
		Textlabel.visible_characters = 1
		var ctext = txtarray[t]
		typing = true
		typeit(ctext)
		await finish
		await confirm
	typing = false
	emit_signal("done")

func splitline(Alltext):
	var txtarray: PackedStringArray = [""]
	txtarray = Alltext.replace("\n","NLN|N").replace("/n","\n").split("NLN|N")
	return
	
