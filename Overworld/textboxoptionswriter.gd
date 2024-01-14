extends GenericTextTyper

signal finishedtyping
func typetext(Text = "Blank"):
	typing = true
	if typeof(Text) != TYPE_ARRAY and typeof(Text) != TYPE_PACKED_STRING_ARRAY: Text = [Text]
	for i in Text.size():
		emit_signal("startedtyping", i)
		await _type_one_line(Text[i])
		if i == Text.size() - 1:
			emit_signal("finishedtyping")
		await confirm
	emit_signal("finishedalltexts")
	typing = false
