extends GenericTextTyper
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


func typetext(Text: Variant = "Blank") -> void:
	typing = true
	if typeof(Text) != TYPE_ARRAY and typeof(Text) != TYPE_PACKED_STRING_ARRAY: Text = [Text]
	for i: int in Text.size():
		started_typing.emit(i)
		await _type_one_line(Text[i])
		await confirm
		get_viewport().set_input_as_handled()
	finished_all_texts.emit()
	typing = false
