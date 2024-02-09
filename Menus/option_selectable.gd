extends RichTextLabel
class_name OptionSelectable

@export var selected := false : 
	set = set_selected
	

func _ready() -> void:
	set_selected(selected)


func set_selected(new_val: bool) -> void:
	selected = new_val
	if new_val:
		self_modulate = Color.YELLOW
		return
	self_modulate = Color.WHITE

func reset():
	set_selected(false)
