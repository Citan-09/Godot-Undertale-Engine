extends AspectRatioContainer

signal finished
# Called when the node enters the scene tree for the first time.
func play():
	$VideoStreamPlayer.play()
	await $VideoStreamPlayer.finished
	emit_signal("finished")
	pass # Replace with function body.

