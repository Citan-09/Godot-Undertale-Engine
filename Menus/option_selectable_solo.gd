extends OptionSelectable
class_name OptionSelectableSolo

@export var enabled := true : set = set_enabled

@export var offset := Vector2.ZERO
@export_subgroup("Surrounding Options")
@export var NodeUp: OptionSelectable
@export var NodeDown: OptionSelectable
@export var NodeLeft: OptionSelectable
@export var NodeRight: OptionSelectable

@export var NodeAccept: OptionSelectable

signal accept_pressed
signal move_soul_request(pos: Vector2)

func set_enabled(new_val: bool) -> void:
	enabled = new_val


func enable() -> void:
	enabled = true

func disable() -> void:
	enabled = false


func _ready() -> void:
	set_selected(Selected)
	if !Selected:
		return
	move_soul(self)


func set_selected(new_val: bool) -> void:
	selected = new_val
	set_process_unhandled_input(new_val)
	if new_val:
		self_modulate = selected_color
		return
	self_modulate = default_color


func reset() -> void:
	set_selected(false)


func _unhandled_input(event: InputEvent) -> void:
	if !is_visible_in_tree() or !enabled:
		return
	if event.is_action_pressed("ui_down"):
		move_soul(NodeDown)
		AudioPlayer.play("choice")
	if event.is_action_pressed("ui_up"):
		move_soul(NodeUp)
		AudioPlayer.play("choice")
	if event.is_action_pressed("ui_left"):
		move_soul(NodeLeft)
		AudioPlayer.play("choice")
	if event.is_action_pressed("ui_right"):
		move_soul(NodeRight)
		AudioPlayer.play("choice")
	if event.is_action_pressed("ui_accept"):
		move_soul(NodeAccept)
		AudioPlayer.play("select")
		accept_pressed.emit()

	

func move_soul(node: OptionSelectable) -> void:
	get_viewport().set_input_as_handled()
	if !node:
		return
	move_soul_request.emit(node.global_position + offset)
	selected = false
	node.selected = true
	
