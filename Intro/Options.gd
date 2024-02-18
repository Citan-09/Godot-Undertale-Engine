extends ReferenceRect

signal confirm_name
signal backspace
signal enter_typing

var current_pos: int = 0: set = set_current_pos

@export var Choice: AudioStreamPlayer

@onready var Options := get_children()


func _ready() -> void:
	set_process_unhandled_input(false)


func set_current_pos(pos: int) -> void:
	current_pos = posmod(pos, 3)
	

func enable() -> void:
	Choice.play()
	set_process_unhandled_input(true)
	refresh_thing()
	

func disable() -> void:
	Options[current_pos].selected = false
	enter_typing.emit()
	set_process_unhandled_input(false)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down"):
		disable()
	if event.is_action_pressed("ui_left"):
		refresh_thing(-1)
	if event.is_action_pressed("ui_right"):
		refresh_thing(1)
	if event.is_action_pressed("ui_accept"):
		match current_pos:
			0:
				await create_tween().tween_property($"../", "modulate:a", 0, 0.8).set_trans(Tween.TRANS_SINE).finished
				get_tree().change_scene_to_file(ProjectSettings.get_setting("application/run/main_scene"))
			1:
				backspace.emit()
			2:
				confirm_name.emit()
	

func refresh_thing(action: int = 0) -> void:
	if action: Choice.play()
	Options[current_pos].selected = false
	current_pos += action
	while Options[current_pos] == null:
		current_pos += action
	Options[current_pos].selected = true
