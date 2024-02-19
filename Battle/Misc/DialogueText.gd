extends AdvancedTextTyper
class_name EnemySpeech

@export var current_character: characters = characters.GENERIC
enum characters {
	GENERIC,
	SANS,
	PAPYRUS,
	UNDYNE,
	UNDYNE_UNDYING,
	ALPHYS,
	ASGORE,
	FLOWEY,
	FLOWEY_EVIL,
	GASTER,
	METTATON,
	TEMMIE,
	TORIEL
}

func character_customize() -> void:
	match current_character:
		characters.PAPYRUS:
			currentfont = load("res://Text/Fonts/papyrus.ttf")
		characters.SANS:
			currentfont = load("res://Text/Fonts/pixel-comic-sans-undertale-sans-font.ttf")
		characters.TEMMIE:
			entire_text_bbcode = "[shake amp=6]"


func type_text_advanced(dialogues: Dialogues) -> void:
	typing = true
	var expressions: Array = dialogues.get_dialogues_single(Dialogues.DIALOGUE_EXPRESSIONS)
	for i: int in dialogues.dialogues.size():
		started_typing.emit(i)
		expression_set.emit(expressions[i])
		pauses = dialogues.dialogues[i].pauses
		await type_buffer(dialogues, i)
		await confirm
		get_viewport().set_input_as_handled()
	finished_all_texts.emit()
	typing = false
