@icon("res://Overworld/textboxicon.png")
extends CanvasLayer
class_name TextBox

var soulpos: Variant = 0
var soul_position := Vector2.ZERO
var selecting: bool = false
var optionamt: int = 0

const SUMMON_DURATION: float = 0.2
const TransType := Tween.TRANS_QUAD

var talking_character := DEFAULT
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

@onready var Text: AdvancedTextTyper = $Control/TextContainer/Text
@onready var Options: Array[GenericTextTyper] = [
	$Control/TextContainer/Options/First,
	$Control/TextContainer/Options/Second,
	$Control/TextContainer/Options/Third,
	$Control/TextContainer/Options/Fourth
]
@onready var defpos: Vector2 = $Control.position
@onready var defsize: Vector2 = $Control.size

signal selected_option(option: int)
signal character_talk


func _ready() -> void:
	$Control/Speaker.modulate.a = 0
	$Control/Speaker.hide()
	$Control.modulate.a = 0
	Text.text = ""
	for i in Options.size():
		Options[i].text = ""

func _summon_box() -> void:
	var tw := create_tween().set_parallel().set_trans(TransType)
	tw.tween_property($Control, "modulate:a", 1.0, SUMMON_DURATION)
	await get_tree().create_timer(SUMMON_DURATION / 2.0, false).timeout

func _dismiss_box() -> void:
	var tw := create_tween().set_parallel().set_trans(TransType)
	tw.tween_property($Control, "modulate:a", 0, SUMMON_DURATION)
	await tw.finished
	queue_free()


## WARNING: don't use this!
func abstract(text: Dialogues, options: PackedStringArray = [], text_after_options: Array[Dialogues] = []) -> void:
	Global.player_in_menu = true
	await _summon_box()
	Text.type_text_advanced(text)

	await Text.finished_typing
	for i: int in min(options.size(), 4):
		Options[i].show()
	for i: int in min(options.size(), 4):
		Options[i].type_text_advanced(Dialogues.new().from([options[i]]))
		await Options[i].finished_typing
	if options.size():
		$Control/Soul.show()
		selecting = true
		optionamt = options.size()
		soulpos = (optionamt - 1) / 2.0
		$Control/Soul/choice.play()
		soul_position = Vector2(320, Options[0].global_position.y)
		$Control/Soul.global_position = Vector2(320, Options[0].global_position.y)
		await selected_option
	else:
		await Text.finished_all_texts
	get_viewport().set_input_as_handled()
	$Control/Soul.hide()
	for i in Options.size():
		Options[i].text = ""
		Options[i].hide()
	if text_after_options.size() > soulpos and text_after_options[soulpos]:
		await Text.type_text_advanced(text_after_options[soulpos])
	Text.text = ""
	Global.player_in_menu = false
	_dismiss_box()

func generic(text: Dialogues, options: PackedStringArray = [], text_after_options: Array[Dialogues] = []) -> void:
	for i in Options.size() + 1:
		if i == 0:
			Text.click = get_node(char_sound[DEFAULT])
		else:
			Options[i -1].click = get_node(char_sound[DEFAULT])
	await abstract(text, options, text_after_options)


func character(chr: int, dialogues: Dialogues, options: PackedStringArray = [], dialogues_after_options: Array[Dialogues] = []) -> void:
	$Control/Speaker.show()
	var tw := create_tween()
	tw.tween_property($Control/Speaker, "modulate:a", 1, 0.3)
	$Control/Speaker/Head.animation = char_head[chr]
	Text.currentfont = char_font.get(chr)
	for i in Options.size() + 1:
		if i == 0:
			Text.click = get_node(char_sound[chr])
		else:
			Options[i -1].click = get_node(char_sound[chr])

	await abstract(dialogues, options, dialogues_after_options)
	tw = create_tween()
	tw.tween_property($Control/Speaker, "modulate:a", 0, 0.3)


func set_head_frame(expr: Array[int]) -> void:
	$Control/Speaker/Head.frame = expr[0]

func _input(event: InputEvent) -> void:
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
			selected_option.emit(soulpos)
			selecting = false
			$Control/Soul/select.play()


func _process(delta: float) -> void:
	$Control/Soul.global_position = $Control/Soul.global_position.lerp(soul_position, delta * 40)


func _on_text_click_played() -> void:
	character_talk.emit()
