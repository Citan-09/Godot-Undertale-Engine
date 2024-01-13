@icon("res://Overworld/textboxicon.png")
extends CanvasLayer
class_name TextBox

var soulpos = 0
var soul_position := Vector2.ZERO
var selecting: bool = false
var optionamt: int = 0

@export var summon_duration = 0.6
@export var transtype := Tween.TRANS_EXPO
var talking_character = DEFAULT
## Characters (add as needed)
enum {
	DEFAULT,
	SANS,
	PAPYRUS,
	UNDYNE,
	UNDYNE_THE_UNDYING,
	ALPHYS,
	ASGORE,
	FLOWEY,
	FLOWEY_EVIL,
	GASTER,
	METTATON,
	TEMMIE,
	TORIEL,
}

## Character Talk Sounds (add as needed)
var char_sound := {
	DEFAULT: ^"Sounds/Generic",
	SANS: ^"Sounds/Sans",
	PAPYRUS: ^"Sounds/Papyrus",
	UNDYNE: ^"Sounds/Undyne",
	UNDYNE_THE_UNDYING: ^"Sounds/UndyneTheUndying",
	ALPHYS: ^"Sounds/Alphys",
	ASGORE: ^"Sounds/Asgore",
	FLOWEY: ^"Sounds/Flowey",
	FLOWEY_EVIL: ^"Sounds/FloweyEvil",
	GASTER: ^"Sounds/Gaster",
	METTATON: ^"Sounds/Mettaton",
	TEMMIE: ^"Sounds/Temmie",
	TORIEL: ^"Sounds/Toriel",
}

## Character font (for sand and papyru)
var char_font := {
	SANS: load("res://Text/Fonts/pixel-comic-sans-undertale-sans-font.ttf"),
	PAPYRUS: load("res://Text/Fonts/papyrus.ttf")
}

var char_head := {
	SANS: "sans",
	PAPYRUS: "papyrus",
	UNDYNE: "undyne",
	UNDYNE_THE_UNDYING: "undyne_undying",
	ALPHYS: "alphys",
	ASGORE: "asgore",
	FLOWEY: "flowey",
	FLOWEY_EVIL: "flowey_evil",
	METTATON: "mettaton",
	TORIEL: "toriel",
}

@onready var Text: GenericTextTyper = $Control/TextContainer/Text
@onready var Options: Array[GenericTextTyper] = [
	$Control/TextContainer/Options/First,
	$Control/TextContainer/Options/Second,
	$Control/TextContainer/Options/Third,
	$Control/TextContainer/Options/Fourth
]
@onready var defpos = $Control.position
@onready var defsize = $Control.size

signal confirm

signal selected_option(option)
func _ready():
	$Control/Speaker.modulate.a = 0
	$Control/Speaker.hide()
	$Control.modulate.a = 0
	$Control.size.x = 0
	Text.text = ""
	for i in Options.size():
		Options[i].text = ""

func _summon_box():
	var tw = create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(transtype)
	tw.tween_property($Control, "size:x", defsize.x, summon_duration)
	tw.tween_property($Control, "position:x", defpos.x, summon_duration).from(320)
	tw.tween_property($Control, "modulate:a", 1.0, summon_duration)
	await get_tree().create_timer(summon_duration / 2.0, false).timeout

func _dismiss_box():
	var tw = create_tween().set_parallel().set_ease(Tween.EASE_IN).set_trans(transtype)
	tw.tween_property($Control, "size:x", 0, summon_duration)
	tw.tween_property($Control, "position:x", 320, summon_duration)
	tw.tween_property($Control, "modulate:a", 0, summon_duration)
	await get_tree().create_timer(summon_duration, false).timeout
	queue_free()

func generic(text: PackedStringArray, options: PackedStringArray = [], text_after_options: Array = []):
	for i in Options.size() + 1:
		if i == 0:
			Text.click = get_node(char_sound[DEFAULT])
		else:
			Options[i -1].click = get_node(char_sound[DEFAULT])
	Global.player_in_menu = true
	await _summon_box()
	Text.typetext(text)
	await Text.finishedtyping
	for i in min(options.size(), 4):
		Options[i].show()
	for i in min(options.size(), 4):
		Options[i].typetext(options[i])
		await Options[i].finishedtyping
	if options.size():
		$Control/Soul.show()
		selecting = true
		optionamt = options.size()
		soulpos = (optionamt - 1) / 2.0
		$Control/Soul/choice.play()
		soul_position = Vector2(320, Options[0].global_position.y)
		$Control/Soul.global_position = Vector2(320, Options[0].global_position.y)
		await confirm
	else:
		await Text.finishedalltexts
	get_viewport().set_input_as_handled()
	$Control/Soul.hide()
	for i in Options.size():
		Options[i].text = ""
		Options[i].hide()
	if text_after_options.size() > soulpos and text_after_options[soulpos]:
		await Text.typetext(text_after_options[soulpos])
	Text.text = ""
	Global.player_in_menu = false
	_dismiss_box()

func character(character: int, text: PackedStringArray, head_expressions: Array, options: PackedStringArray = [], text_after_options: Array = [], head_expressions_options: Array = []):
	$Control/Speaker.show()
	var tw = create_tween()
	tw.tween_property($Control/Speaker, "modulate:a", 1, 0.3)
	$Control/Speaker/Head.animation = char_head[character]
	for i in Options.size() + 1:
		if i == 0:
			Text.click = get_node(char_sound[character])
		else:
			Options[i -1].click = get_node(char_sound[character])

	Text.startedtyping.connect(set_head_frame)
	Global.player_in_menu = true
	await _summon_box()
	headframestemp = head_expressions
	Text.typetext(text)
	await Text.finishedtyping
	
	for i in min(options.size(), 4):
		Options[i].show()
	for i in min(options.size(), 4):
		Options[i].typetext(options[i])
		await Options[i].finishedtyping
	if options.size():
		$Control/Soul.show()
		selecting = true
		optionamt = options.size()
		soulpos = (optionamt - 1) / 2.0
		$Control/Soul/choice.play()
		soul_position = Vector2(320, Options[0].global_position.y)
		await confirm
	else:
		await Text.finishedalltexts
	get_viewport().set_input_as_handled()
	$Control/Soul.hide()
	for i in Options.size():
		Options[i].text = ""
		Options[i].hide()
	if text_after_options.size() > soulpos and text_after_options[soulpos]:
		headframestemp = head_expressions_options[soulpos]
		await Text.typetext(text_after_options[soulpos])
	Text.text = ""
	Global.player_in_menu = false
	tw = create_tween()
	tw.tween_property($Control/Speaker, "modulate:a", 0, 0.3)
	_dismiss_box()

var headframestemp: Array
func set_head_frame(counter: int):
	$Control/Speaker/Head.frame = headframestemp[counter]

func _unhandled_input(event):
	if selecting:
		if event.is_action_pressed("ui_left") and soulpos > 0:
			soulpos = int(soulpos - 1)
			$Control/Soul/choice.play()
			soul_position = Options[soulpos].global_position
		if event.is_action_pressed("ui_right") and soulpos < optionamt - 1:
			soulpos = int(soulpos + 1)
			$Control/Soul/choice.play()
			soul_position = Options[soulpos].global_position
		if event.is_action_pressed("ui_accept") and typeof(soulpos) == TYPE_INT:
			get_viewport().set_input_as_handled()
			emit_signal("confirm")
			selecting = false
			$Control/Soul/select.play()


func _process(delta):
	$Control/Soul.global_position = $Control/Soul.global_position.lerp(soul_position, delta * 40)
