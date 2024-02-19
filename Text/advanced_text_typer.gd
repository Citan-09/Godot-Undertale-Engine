class_name AdvancedTextTyper extends GenericTextTyper


signal click_played
signal expression_set(expr: Array[int])


var pauses: Array[DialoguePause] = []

func type_text(_a: PackedStringArray) -> void:
	push_error("Don't use this here")


func type_text_advanced(dialogues: Dialogues) -> void:
	typing = true
	var expressions: Array = dialogues.get_dialogues_single(Dialogues.DIALOGUE_EXPRESSIONS)
	for i: int in dialogues.size():
		started_typing.emit(i)
		expression_set.emit(expressions[i])
		pauses = dialogues.get_dialogues_single(Dialogues.DIALOGUE_PAUSES)[i]
		await type_buffer(dialogues, i)
		await confirm
	finished_all_texts.emit()
	typing = false

func type_buffer(dialogues: Dialogues, i: int) -> void:
	text_size_counter = 0
	pauses_done_counter = 0
	text = entire_text_bbcode
	var txts: Array = dialogues.get_dialogues_single(Dialogues.DIALOGUE_TEXT)
	await type_buffer_text(txts[i])




func type_buffer_text(txt: String) -> void:
	text = txt
	chache_parsed_text = get_parsed_text()
	createtweeners()
	visible_ratio = 0
	var parsed_text := get_parsed_text()
	visibletween.tween_property(self, "visible_ratio", 1, interval * parsed_text.length())
	soundtween.set_loops(parsed_text.length() + soundtween.get_loops_left())
	soundtween.tween_callback(playclick)
	soundtween.tween_interval(interval)
	await visibletween.finished


func createtweeners() -> void:
	visibletween = create_tween()
	soundtween = create_tween()
	visibletween.tween_interval(interval / 2.0)

var text_size_counter: int = 0
var pauses_done_counter: int = 0

func playclick() -> void:
	text_size_counter += 1
	var currentchar := chache_parsed_text[visible_characters]
	if currentchar in extra_delay:
		if !visibletween.is_valid() or !soundtween.is_valid():
			return
		soundtween.pause()
		visibletween.pause()
		pausetween = create_tween()
		pausetween.tween_callback(visibletween.play).set_delay(
				interval + pauses[pauses_done_counter].pause_duration if pauses.size() - 1 > pauses_done_counter and text_size_counter == pauses[pauses_done_counter].pause_index else interval
				)
		pausetween.tween_callback(soundtween.play).set_delay(
				interval + pauses[pauses_done_counter].pause_duration if pauses.size() - 1 > pauses_done_counter and text_size_counter == pauses[pauses_done_counter].pause_index else interval
				)
		if pauses.size() - 1 > pauses_done_counter and text_size_counter == pauses[pauses_done_counter].pause_index:
			pauses_done_counter += 1
		return
	if currentchar in no_sound:
		return
	click.play()
	click_played.emit()
	return
