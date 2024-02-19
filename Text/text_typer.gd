extends RichTextLabel
class_name GenericTextTyper

@export var click_path: NodePath = ^"Click"
@onready var click: AudioStreamPlayer = get_node(click_path)
@export var interval: float = 0.1
@export var currentfont: FontFile = load("res://Text/Fonts/DTM-Mono.otf")
@export var queued_texts_handling: text_queue_modes = text_queue_modes.AWAIT_FINISH
var pausetween: Tween
var visibletween: Tween
var soundtween: Tween
var chache_parsed_text: String
var typing := false
@export var entire_text_bbcode := ""

var extra_delay := "@#$%^&+=_-~`<>\"|\\*{}()[].,!?"
var no_sound := "@#$%^&+=_-~`<>\"|\\*{}()[].,!? "

enum text_queue_modes {
	AWAIT_FINISH,
	OVERRIDE_CURRENT,
	VOID_QUEUED,
}
signal started_typing(line: int)
signal confirm
signal finished_all_texts

func _process(_delta: float) -> void:
	if currentfont:
		set("theme_override_fonts/normal_font", currentfont)
	else:
		set("theme_override_fonts/normal_font", null)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and visibletween and visibletween.is_running():
		kill_tweens(true)
	if event.is_action_pressed("ui_accept") and (!visibletween or !visibletween.is_running()):
		emit_signal("confirm")

func kill_tweens(complete_text := false) -> void:
	if pausetween and pausetween.is_valid():
		pausetween.kill()
	if soundtween and soundtween.is_valid():
		soundtween.kill()
	if visibletween and visibletween.is_valid():
		if complete_text:
			visibletween.custom_step(10000)
		else:
			visibletween.kill()



func type_text(Text: PackedStringArray) -> void:
	typing = true
	for i: int in Text.size():
		started_typing.emit(i)
		await _type_one_line(Text[i])
		await confirm
	finished_all_texts.emit()
	typing = false

func createtweeners() -> void:
	visibletween = create_tween()
	soundtween = create_tween()


func _type_one_line(line: String) -> bool:
	text = entire_text_bbcode + line
	chache_parsed_text = get_parsed_text()
	match queued_texts_handling:
		text_queue_modes.AWAIT_FINISH:
			while visibletween and visibletween.is_valid() and visibletween.is_running():
				await visibletween.finished
		text_queue_modes.OVERRIDE_CURRENT:
			kill_tweens()
		text_queue_modes.VOID_QUEUED:
			if visibletween and visibletween.is_valid():
				return false
	createtweeners()
	visible_ratio = 0
	var parsed_text := get_parsed_text()
	visibletween.tween_property(self, "visible_ratio", 1, interval * parsed_text.length())
	soundtween.set_loops(parsed_text.length())
	soundtween.tween_interval(interval)
	soundtween.tween_callback(playclick)
	await visibletween.finished
	return true

func playclick() -> void:
	var currentchar := chache_parsed_text[visible_characters]
	if currentchar in extra_delay:
		if !visibletween.is_running() or !soundtween.is_running():
			return
		soundtween.pause()
		visibletween.pause()
		pausetween = create_tween().set_parallel()
		pausetween.tween_callback(visibletween.play).set_delay(interval)
		pausetween.tween_callback(soundtween.play).set_delay(interval)
		return
	if currentchar in no_sound:
		return
	click.play()
	return
