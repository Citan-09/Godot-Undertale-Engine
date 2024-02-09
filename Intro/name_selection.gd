extends Control


var name_text := ""

@onready var NameInput: LineEdit = $NameInput


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(_delta: float) -> void:
	var c: int = NameInput.caret_column
	NameInput.text = NameInput.text.to_upper()
	NameInput.caret_column = c

@warning_ignore("unused_parameter")
func _on_name_input_text_changed(new_text: String) -> void:
	$choice.play()


@warning_ignore("unused_parameter")
func _on_name_input_text_submitted(new_text: String) -> void:
	$select.play()
	NameInput.editable = false
	NameInput.release_focus()
	_check_names.call_deferred(NameInput.text)
	var c: bool = await pass_name
	if !c:
		NameInput.editable = true
		Typer.text = ""
		NameInput.text = ""
		get_viewport().set_input_as_handled()
		return 
	Typer.hide()
	Global.player_name = NameInput.text
	var tw := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_parallel()
	tw.tween_property($NAMEPLS, "modulate:a", 0, 0.3)
	tw.tween_property($Camera, "zoom", Vector2.ONE * 5, 6)
	tw.tween_property($ColorRect, "modulate:a", 1, 6).set_ease(Tween.EASE_IN)
	tw.tween_property($Camera, "position:y", 70, 1).set_trans(Tween.TRANS_LINEAR)
	tw.tween_callback($cymbal.play).set_delay(0.89)
	$Camera.rgbsplit(5, 0.7)
	await tw.finished
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Global.savegame()
	OverworldSceneChanger.enter_room_default()


signal pass_name(allowed: bool)
@onready var Typer: GenericTextTyper = $Typer

## USE THIS TO DO COOL STUFF WITH CUSTOM NAMES
func _check_names(Name: String) -> void:
	match Name:
		"GASTER":
			OS.alert("Error code: -1 \nCannot concatenate type \"Null\" to type \"String\" \nPlease report this error to https://undertale.com", "CRITICAL ERROR!")
			OS.crash("Gaster broke the game!!!!")
			pass_name.emit(false)
			return
		"SANS":
			Typer.typetext(["[center]NO PLEASE"])
			await Typer.finished_all_texts
			pass_name.emit(false)
			return
		"FRISK":
			Typer.typetext(["[center]WARNING: \nThis makes your life hell.\n Proceed anyway?"])
			await Typer.visibletween.finished
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
		$select.play()
		choice.emit(soul_pos)
