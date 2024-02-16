extends GenericTextTyper

@onready var container: MarginContainer = get_parent()
var flavour_texts: PackedStringArray = []

@onready var default_volume: float = get_node(click_path).volume_db

func blitter(turn: int) -> void:
	typetext(flavour_texts[turn % max(flavour_texts.size(), 1)])

func blittertext(alltext: PackedStringArray) -> void:
	typetext(alltext)

func typetext(Text: Variant = "Blank") -> void:
	if typeof(Text) != TYPE_ARRAY and typeof(Text) != TYPE_PACKED_STRING_ARRAY: Text = [Text]
	for i: int in Text.size():
		get_viewport().set_input_as_handled()
		started_typing.emit(i)
		await _type_one_line(Text[i])
		await confirm
	finished_all_texts.emit()


func _process(_delta: float) -> void:
	if !container.visible:
		click.volume_db = -80
	else:
		click.volume_db = default_volume

