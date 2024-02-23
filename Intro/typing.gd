extends Node

@export var margin_letters := Vector2(0, 0)
@export var Choice: AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_create_letters()


const LETTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ\nabcdefghijklmnopqrstuvwxyz"
const LIMIT: int = 7
var selectable_name: Script = preload("res://Menus/option_selectable.gd")


var Letters := [
	[null, null, null, null, null, null, null, null],
	[null, null, null, null, null, null, null, null],
	[null, null, null, null, null, null, null, null],
	[null, null, null, null, null, null, null, null],
	[null, null, null, null, null, null, null, null],
	[null, null, null, null, null, null, null, null],
	[null, null, null, null, null, null, null, null],
]

var current_pos := Vector2i.ZERO: set = set_current_pos

signal letter_input(letter: String)
signal exited_letter(x: int)
signal backspace_key
signal enter_key

func set_current_pos(pos: Vector2i) -> void:
	current_pos = pos
	current_pos.x = posmod(current_pos.x, LIMIT)
	current_pos.y = posmod(current_pos.y, Letters[current_pos.x].size())


func _create_letters() -> void:
	var counter: int = 0
	var margin_current := Vector2(0, 0)
	for case in LETTERS.split("\n"):
		for letter in case:
			var rtlbl: RichTextLabel = RichTextLabel.new()
			rtlbl.set_script(selectable_name)
			rtlbl.theme = preload("res://Text/Fonts/DTMono24.tres")
			rtlbl.custom_effects = [preload("res://Resources/RichTextEffects/tremble.tres")]
			rtlbl.bbcode_enabled = true
			rtlbl.text = "[tremble chance=1 amp=10]%s" % letter
			rtlbl.scroll_active = false
			add_child(rtlbl)
			rtlbl.size = Vector2.ONE * 32
			@warning_ignore("integer_division")
			Letters[counter % LIMIT][counter / LIMIT] = rtlbl
			@warning_ignore("integer_division")
			rtlbl.position = margin_letters * Vector2(counter % LIMIT, counter / LIMIT) + margin_current
			counter += 1
		@warning_ignore("integer_division")
		counter = (counter / LIMIT + 1) * LIMIT
		margin_current += Vector2(0, 8)
	refresh_thing()

func enable_input(x: int) -> void:
	Choice.play()
	refresh_thing()
	set_process_unhandled_input(true)


func disable_input() -> void:
	set_process_unhandled_input(false)
	Letters[current_pos.x][current_pos.y].selected = false
	exited_letter.emit(current_pos.x)

var shift_pressed := false: set = _on_shift_pressed
@onready var Shift: OptionSelectable = $Shift

func _on_shift_pressed(shift: bool) -> void:
	shift_pressed = shift
	$Shift.selected = shift

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_SHIFT:
			shift_pressed = event.is_pressed()
		if shift_pressed and event.is_pressed():
			if event.keycode > 64 and event.keycode < 91:
				letter_input.emit(LETTERS[event.keycode - 65])
				Choice.play()
			if event.keycode == KEY_BACKSPACE:
				backspace_key.emit()
				Choice.play()
			if event.keycode == KEY_ENTER:
				enter_key.emit()
				set_process_unhandled_input(false)
				shift_pressed = false
			return
		
	if shift_pressed:
		return
	if event.is_action_pressed("ui_down"):
		if !current_pos.y < Letters[current_pos.x].size() - 1 or (!Letters[current_pos.x][current_pos.y + 1] and !current_pos.y < Letters[current_pos.x].size() - 2):
			disable_input()
			return
		refresh_thing(Vector2.DOWN)
	if event.is_action_pressed("ui_right"):
		refresh_thing(Vector2.RIGHT)
	if event.is_action_pressed("ui_left"):
		refresh_thing(Vector2.LEFT)
	if event.is_action_pressed("ui_up"):
		refresh_thing(Vector2.UP)
	if event.is_action_pressed("ui_accept"):
		letter_input.emit(Letters[current_pos.x][current_pos.y].get_parsed_text())
	



func refresh_thing(action := Vector2i.ZERO) -> void:
	if action: Choice.play()
	Letters[current_pos.x][current_pos.y].selected = false
	current_pos += action
	while Letters[current_pos.x][current_pos.y] == null:
		current_pos += action
	Letters[current_pos.x][current_pos.y].selected = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	pass
