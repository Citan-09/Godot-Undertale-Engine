extends CanvasItem
class_name OptionSelectable

@export var selected := false : set = set_selected
@export var selected_color := Color.YELLOW
@onready var default_color: Color = self_modulate

func _ready() -> void:
	set_selected(selected)


func set_selected(new_val: bool) -> void:
	selected = new_val
	if new_val:
		self_modulate = selected_color
		return
	self_modulate = default_color

func reset():
	set_selected(false)
