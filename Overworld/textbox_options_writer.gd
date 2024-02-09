extends GenericTextTyper

signal finished_typing
func typetext(Text: Variant = "Blank") -> void:
	typing = true
	if typeof(Text) != TYPE_ARRAY and typeof(Text) != TYPE_PACKED_STRING_ARRAY: Text = [Text]
	for i: int in Text.size():
		started_typing.emit(i)
		await _type_one_line(Text[i])
		if i == Text.size() - 1:
			finished_typing.emit()
		await confirm
	finished_all_texts.emit()
	typing = false
