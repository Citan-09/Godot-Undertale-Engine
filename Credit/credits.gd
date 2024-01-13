extends TextTyperGeneric

func _input(event):
	if event.is_action_pressed("Confirm"):
		emit_signal("confirm")

func _ready():
	if Data.settings["vfxmult"]:
		$VhsCrt.show()
	time = 0.04
	Textlabel = $RichTextLabel
	sound = $Click
	Textlabel.visible_characters = 0
	startcredits()
	
func startcredits():
	var tw = get_tree().create_tween()
	tw.tween_property(Textlabel,"position:y",0,10)
	typetext(Textlabel.text,false)
	await done
	tw = get_tree().create_tween()
	tw.tween_property(self,"modulate:a",0,1)
	await tw.finished
	get_tree().change_scene_to_file("res://Menu/menu.tscn")


