extends Control

var name_text = ""
# Called when the node enters the scene tree for the first time.
func _ready():
	typer.set_process_unhandled_input(false)

func _process(delta):
	var c = $NameInput.caret_column
	$NameInput.text = $NameInput.text.to_upper()
	$NameInput.caret_column = c

func _on_name_input_text_changed(new_text):
	$choice.play()


func _on_name_input_text_submitted(new_text):
	$select.play()
	_check_names($NameInput.text)
	await allow_name
	$Typer.hide()
	Global.player_name = $NameInput.text
	$NameInput.editable = false
	var tw = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_parallel()
	tw.tween_property($NAMEPLS, "modulate:a", 0, 0.3)
	tw.tween_property($Camera, "zoom", Vector2.ONE * 5, 6)
	tw.tween_property($ColorRect, "modulate:a", 1, 6).set_ease(Tween.EASE_IN)
	tw.tween_property($Camera, "position:y", 70, 1).set_trans(Tween.TRANS_LINEAR)
	tw.tween_callback($cymbal.play).set_delay(0.89)
	$Camera.rgbsplit(5, 0.7)
	await tw.finished
	Global.savegame()
	get_tree().change_scene_to_file("res://Overworld/overworld_room_loader.tscn")


signal allow_name
@onready var typer = $Typer

## USE THIS TO DO COOL STUFF WITH CUSTOM NAMES
func _check_names(Name: String):
	match Name:
		"GASTER":
			OS.alert("error code: -2147483648", "CRITICAL ERROR!!!!!")
			get_tree().paused = true
			get_tree().quit()
			return
		"SANS":
			typer.typetext(["[center]NO PLEASE"])
			await typer.visibletween.finished
			return
	emit_signal.call_deferred("allow_name")

