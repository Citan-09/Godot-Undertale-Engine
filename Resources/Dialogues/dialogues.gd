extends Resource
class_name Dialogues

@export var dialogues: Array[Dialogue] = []

enum {
	DIALOGUE_TEXT,
	DIALOGUE_EXPRESSIONS,
	DIALOGUE_EXPRESSION_HEAD,
	DIALOGUE_EXPRESSION_BODY,
}

func get_dialogues_single(dialog_type: int) -> Array:
	var arr = []
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
	return arr
