extends ReferenceRect

signal confirm_name
signal backspace
signal enter_typing(x: int)

var current_pos: int = 0: set = set_current_pos


@onready var Options := get_children()


func _ready() -> void:
	set_process_unhandled_input(false)


func set_current_pos(pos: int) -> void:
	current_pos = posmod(pos, 3)
	

func enable(x: int) -> void:
	AudioPlayer.play("choice")
	current_pos = 0
	@warning_ignore("integer_division")
	refresh_thing(0 if x < 2 else 1 if x < 5 else 2)
	set_process_unhandled_input(true)
	refresh_thing()
	

func disable() -> void:
	Options[current_pos].selected = false
	enter_typing.emit(current_pos)
	set_process_unhandled_input(false)

func _unhandled_input(event: InputEvent) -> void:
	if !visible:
		return
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
	if action: AudioPlayer.play("choice")
	Options[current_pos].selected = false
	current_pos += action
	while Options[current_pos] == null:
		current_pos += action
	Options[current_pos].selected = true
