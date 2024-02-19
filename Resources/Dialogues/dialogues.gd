extends Resource
class_name Dialogues

@export var dialogues: Array[Dialogue] = []


enum {
	DIALOGUE_TEXT,
	DIALOGUE_EXPRESSIONS,
	DIALOGUE_EXPRESSION_HEAD,
	DIALOGUE_EXPRESSION_BODY,
	DIALOGUE_PAUSES,
}

func get_dialogues_single(dialog_type: int) -> Array:
	var arr := []
	for i in dialogues.size():
		match dialog_type:
			DIALOGUE_TEXT:
				arr.append(dialogues[i].dialog_text)
			DIALOGUE_EXPRESSIONS:
				arr.append(dialogues[i].dialog_expressions)
			DIALOGUE_EXPRESSION_HEAD:
				arr.append(dialogues[i].dialog_expressions[0])
			DIALOGUE_EXPRESSION_BODY:
				arr.append(dialogues[i].dialog_expressions[1])
			DIALOGUE_PAUSES:
				if dialogues[i].pauses == []:
					continue
				arr.append(dialogues[i].pauses)
	return arr

func from(text: PackedStringArray) -> Dialogues:
	for s in text:
		var _d = Dialogue.new()
		_d.dialog_text = s
		dialogues.append(_d)
	return self

