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

func character_customize():
	match current_character:
		characters.PAPYRUS:
			currentfont = load("res://Text/Fonts/papyrus.ttf")
		characters.SANS:
			currentfont = load("res://Text/Fonts/pixel-comic-sans-undertale-sans-font.ttf")
		characters.TEMMIE:
			entire_text_bbcode = "[shake amp=6]"


