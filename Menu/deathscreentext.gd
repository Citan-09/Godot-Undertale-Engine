extends TextTyperGeneric

func _ready():
	Textlabel = $"."
	sound = $Sound
	time = 0.07
	typetext(Textlabel.text)
	await finish
	var tw = get_tree().create_tween()
	tw.tween_property($Options,"modulate:a",1,0.4)


