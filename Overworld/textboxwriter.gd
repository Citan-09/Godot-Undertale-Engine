extends AdvancedTextTyper

signal finished_typing

func type_text_advanced(Text: Dialogues) -> void:
	typing = true
	var expressions: Array = Text.get_dialogues_single(Dialogues.DIALOGUE_EXPRESSIONS)
	for i: int in Text.dialogues.size():
		started_typing.emit(i)
		expression_set.emit(expressions[i])
		await type_buffer(Text, i)
		if i == Text.dialogues.size() - 1:
			finished_typing.emit()
		await confirm
		get_viewport().set_input_as_handled()
	finished_all_texts.emit()
	typing = false


