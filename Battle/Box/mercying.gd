extends BattleBoxBehaviour

func _on_gain_control():
	if Box.history[Box.button_choice][1]:
		Box.soulposition = Box.history[Box.button_choice][1]
	Box.soul_choice(Vector2.ZERO)
	Box.set_mercy_options()
	Box.Screens[Box.State.Mercying].show()

func input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Box.backout()
		Box.moved_to_buttons.emit()
	if event.is_action_pressed("ui_accept"):
		Box.blitter_mercy()
		await Box.BlitterText.finished_all_texts
		Box.mercy.emit(Box.current_target_id)
	return 

func _on_lose_control() -> void:
	Box.history[Box.button_choice][1] = Box.soulposition
	Box.Screens[Box.State.Mercying].hide()
