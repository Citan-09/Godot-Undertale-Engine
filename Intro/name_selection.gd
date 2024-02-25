extends Control


var name_text := ""

@onready var Name: Label = $Name
@onready var No: AudioStreamPlayer = $no


signal disable
signal enable



func _on_name_input_text_changed(new_text: String) -> void:
	if Name.text.length() >= 6:
		return
	Name.text += new_text


func _on_backspace_pressed() -> void:
	if Name.text.length() < 1:
		return
	Name.text = Name.text.left(-1)


func _on_name_input_text_submitted() -> void:
	if !Name.text:
		AudioPlayer.play("hurt")
		emit_signal.call_deferred("enable")
		return
	disable.emit()
	AudioPlayer.play("select")
	_check_names.call_deferred(Name.text.to_upper())
	var allowed: bool = await pass_name
	if !allowed:
		enable.emit()
		Typer.text = ""
		Name.text = ""
		get_viewport().set_input_as_handled()
		return
	Typer.hide()
	Global.player_name = Name.text
	var tw := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_parallel()
	tw.tween_property($Prompt, "modulate:a", 0, 0.3)
	tw.tween_property($Camera, "zoom", Vector2.ONE * 5, 6)
	tw.tween_property($ColorRect, "modulate:a", 1, 6).set_ease(Tween.EASE_IN)
	tw.tween_property($Camera, "position:y", 100, 1).set_trans(Tween.TRANS_LINEAR)
	tw.tween_callback($cymbal.play).set_delay(0.89)
	$Camera.rgbsplit(5, 0.7)
	await tw.finished
	Global.save_game()
	OverworldSceneChanger.enter_room_default()


signal pass_name(allowed: bool)
@onready var Typer: GenericTextTyper = $Typer

## USE THIS TO DO COOL STUFF WITH CUSTOM NAMES
func _check_names(_name: String) -> void:
	match _name:
		"GASTER":
			OS.alert("Error code: -1 \nCannot concatenate type \"Null\" to type \"String\" \nPlease report this error to https://undertale.com", "CRITICAL ERROR!")
			OS.crash("Gaster broke the game!!!!")
			pass_name.emit(false)
			return
		"SANS":
			react_to_name("[center]NO!!!!!", true)
		"FRISK":
			react_to_name("[center]WARNING: \nThis makes your life hell.\n Proceed anyway?")
		_:
			pass_name.emit(true)


func react_to_name(text: String, deny := false) -> void:
	Typer.type_text([text])
	await Typer.visibletween.finished
	if deny:
		await Typer.confirm
		pass_name.emit(false)
		return
	await _await_confirm()
	pass_name.emit(true)

var confirmable := false
@onready var Choices: Array[OptionSelectable] = [$Confirmation/YES, $Confirmation/NO]
signal choice(id: int)

func _await_confirm() -> void:
	Choices[1].reset()
	Choices[0].selected = true
	soul_pos = 0
	$Confirmation.show()
	confirmable = true
	var c: bool = await choice as bool
	$Confirmation.hide()
	confirmable = false
	pass_name.emit(!c)
	return


var soul_pos: int = 0

func _input(event: InputEvent) -> void:
	if !confirmable: return
	if event.is_action_pressed("ui_right"):
		$choice.play()
		Choices[0].reset()
		Choices[1].selected = true
		soul_pos = 1
	if event.is_action_pressed("ui_left"):
		$choice.play()
		Choices[1].reset()
		Choices[0].selected = true
		soul_pos = 0
	if event.is_action_pressed("ui_accept"):
		AudioPlayer.play("select")
		choice.emit(soul_pos)
