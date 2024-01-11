extends GenericTextTyper

@onready var container = get_parent()
var flavour_texts : PackedStringArray = []

@onready var default_volume= $Click.volume_db
func blitter(turn: int):
	typetext(flavour_texts[turn % max(flavour_texts.size(),1)])
	
func blittertext(alltext):
	typetext(alltext)

func typetext(Text= "Blank"):
	if typeof(Text) != TYPE_ARRAY and typeof(Text) != TYPE_PACKED_STRING_ARRAY: Text = [Text]
	for i in Text.size():
		_on_start_typing(i)
		emit_signal("startedtyping",i)
		await _type_one_line(Text[i])
		await confirm
	emit_signal("finishedalltexts")

func _process(delta: float) -> void:
	if !container.visible:
		click.volume_db = -80
	else:
		click.volume_db = default_volume
	
