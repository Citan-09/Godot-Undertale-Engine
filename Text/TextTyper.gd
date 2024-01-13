extends RichTextLabel
class_name GenericTextTyper

@export var click_path: NodePath = ^"Click"
@onready var click = get_node(click_path)
@export var interval = 0.1
@export var currentfont: FontFile = load("res://Text/Fonts/DTM-Mono.otf")
@export var queued_texts_handling: text_queue_modes = text_queue_modes.AWAIT_FINISH
var visibletween: Tween
var soundtween: Tween
var chache_parsed_text
var typing := false
@export var entire_text_bbcode := ""

var extra_delay := "@#$%^&+=_-~`<>\"|\\*{}()[].,!?"
var no_sound := "@#$%^&+=_-~`<>\"|\\*{}()[].,!? "

enum text_queue_modes {
	AWAIT_FINISH,
	OVERRIDE_CURRENT,
	VOID_QUEUED,
}
signal startedtyping(line: int)
signal confirm
signal finishedalltexts
func _process(delta: float) -> void:
	if currentfont:
		set("theme_override_fonts/normal_font", currentfont)
	else:
		set("theme_override_fonts/normal_font", null)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and visibletween and visibletween.is_running():
		soundtween.kill()
		visibletween.custom_step(10000)
		get_viewport().set_input_as_handled()
	if event.is_action_pressed("ui_accept") and (!visibletween or !visibletween.is_running()):
		emit_signal("confirm")


func _on_start_typing(number):
	pass

func typetext(Text = "Blank"):
	typing = true
	if typeof(Text) != TYPE_ARRAY and typeof(Text) != TYPE_PACKED_STRING_ARRAY: Text = [Text]
	for i in Text.size():
		_on_start_typing(i)
		emit_signal("startedtyping", i)
		await _type_one_line(Text[i])
		await confirm
	emit_signal("finishedalltexts")
	typing = false

func createtweeners():
	visibletween = create_tween()
	soundtween = create_tween()
	visibletween.tween_interval(interval / 2.0)
func _type_one_line(line: String):
	text = entire_text_bbcode + line
	chache_parsed_text = get_parsed_text()
	match queued_texts_handling:
		text_queue_modes.AWAIT_FINISH:
			while visibletween and visibletween.is_valid():
				await get_tree().process_frame
		text_queue_modes.OVERRIDE_CURRENT:
			if visibletween:
				visibletween.kill()
				visibletween = null
			if soundtween:
				soundtween.kill()
				soundtween = null
		text_queue_modes.VOID_QUEUED:
			if visibletween and visibletween.is_valid():
				return false
	createtweeners()
	visible_ratio = 0
	var parsed_text = get_parsed_text()
	visibletween.tween_property(self, "visible_ratio", 1, interval * parsed_text.length())
	soundtween.set_loops(parsed_text.length() + soundtween.get_loops_left())
	soundtween.tween_callback(playclick)
	soundtween.tween_interval(interval)
	await visibletween.finished
	return true

func playclick():
	var currentchar = chache_parsed_text[visible_characters]
	if currentchar in extra_delay:
		soundtween.pause()
		visibletween.pause()
		var pausetween = create_tween()
		pausetween.tween_callback(visibletween.play).set_delay(interval)
		pausetween.tween_callback(soundtween.play).set_delay(interval)
		return false
	if currentchar in no_sound:
		return false
	click.play()
	return true
