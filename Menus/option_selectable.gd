extends CanvasItem
class_name OptionSelectable

@onready var default_color: Color = self_modulate

@export var Selected := false
@export var selected_color := Color.YELLOW
var selected := false : set = set_selected


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
