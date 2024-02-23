extends AdvancedTextTyper

signal finished_typing
func type_text_advanced(dialogues: Dialogues) -> void:
	typing = true
	var expressions: Array = dialogues.get_dialogues_single(Dialogues.DIALOGUE_EXPRESSIONS)
	for i: int in dialogues.dialogues.size():
		started_typing.emit(i)
		expression_set.emit(expressions[i])
		pauses = dialogues.dialogues[i].pauses
		await type_buffer(dialogues, i)
		if i == dialogues.dialogues.size() - 1:
			finished_typing.emit()
		await confirm
	finished_all_texts.emit()
	typing = false
