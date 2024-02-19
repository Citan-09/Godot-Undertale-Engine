extends InteractionTrigger
class_name ItemInteraction

enum Decisions {
	ITEM_PICK_UP,
	ITEM_LEAVE_ALONE,
}

@export_multiline var discover_text: PackedStringArray = [
	"There is a {ITEM} here.",
	"Pick it up?",
]
@export_multiline var accept_text: PackedStringArray = [
	"{ITEM} was added to your [color=yellow]ITEMS[/color].",
]
@export_multiline var reject_text: PackedStringArray = [
	"{ITEM} was left on the floor.",
]
@export_multiline var full_text: PackedStringArray = [
	"Your inventory is too full.",
]
@export var option_names: PackedStringArray = [
	"Yes",
	"No",
]

@export var item_id: int = 0
var text_box: PackedScene = preload("res://Overworld/text_box.tscn")

signal took_item

func discover() -> void:
	var _txtbox := text_box.instantiate() as TextBox
	add_child(_txtbox)
	_txtbox.generic(Dialogues.new().from(discover_text), option_names, [Dialogues.new().from(accept_text if Global.items.size() != 8 else full_text), Dialogues.new().from(reject_text)])
	var decision: int = await _txtbox.selected_option
	if !decision and Global.items.size() != 8:
		Global.items.append(item_id)
		took_item.emit()
		$PickUp.play()

func disable_item() -> void:
	position = Vector2.INF
	monitoring = false
	monitorable = false
