class_name ListSelectable extends RichTextLabel

@export var offset := Vector2(-8, -16)
@export var Selected: int = 0
@export var bbcode_selected := "[color=yellow]"
@export var bbcode_default := ""

var selected: int = 0 : set = set_selected

@onready var VScroll: VScrollBar = get_child(0, true)

@onready var options: PackedStringArray = text.split("\n", true)

var regex := RegEx.new()

signal accepted_option(id: int)

func set_selected(new_val: int) -> void:
	selected = posmod(new_val, options.size())
	var modified_options: Array = options
	modified_options = modified_options.map(
		func(string: String) -> String:
			if !regex.search(bbcode_default):
				return string
			var result: Array[RegExMatch] = regex.search_all(bbcode_default)
			var strings: PackedStringArray
			for n in result.size():
				strings.append("[/" + result[n].strings[0].substr(1) + "]")
			strings.reverse()
			return self.bbcode_default + string + "".join(strings)
	)
	if !regex.search(bbcode_selected):
		text = "\n".join(modified_options)
		return
	var result: Array[RegExMatch] = regex.search_all(bbcode_selected)
	var strings: PackedStringArray
	for n in result.size():
		strings.append("[/" + result[n].strings[0].substr(1) + "]")
	strings.reverse()
	modified_options[selected] = bbcode_selected + modified_options[selected] + "".join(strings)
	text = "\n".join(modified_options)



func set_options(new_options: PackedStringArray) -> void:
	options = new_options
	set_selected(selected)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	regex.compile("(\\[[A-Za-z]*[^\\]= ])")
	selected = Selected


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


@export var key_down: StringName = &"ui_down"
@export var key_up: StringName = &"ui_up"


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(key_down):
		selected += 1
		AudioPlayer.play("choice")
	if event.is_action_pressed(key_up):
		selected -= 1
		AudioPlayer.play("choice")
	if event.is_action_pressed("ui_accept"):
		accepted_option.emit(selected)
		AudioPlayer.play("select")

