extends CanvasItem
class_name OptionSelectable

@onready var default_color: Color = self_modulate

@export var Selected := false
var selected := false : set = set_selected
@export var selected_color := Color.YELLOW


func _ready() -> void:
	set_selected(Selected)


func set_selected(new_val: bool) -> void:
	selected = new_val
	if new_val:
		self_modulate = selected_color
		return
	self_modulate = default_color

func reset():
	set_selected(false)
