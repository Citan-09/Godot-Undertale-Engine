extends BattleBoxBehaviour

func _on_gain_control() -> void:
	Box.Screens[Box.State.Blittering].show()
	if Box.ActionMemory.size() > 1:
		Box.exit_menu.emit()
	await Box.BlitterText.finished_all_texts
	Box.disable()

func input(event: InputEvent) -> void:
	if !Box.BlitterText.typing:
		return
	if event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
	return

func _on_lose_control() -> void:
	Box.Screens[Box.State.Blittering].hide()


