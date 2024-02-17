extends BattleBoxBehaviour


func _on_gain_control() -> void:
	if Box.history[Box.button_choice][1]:
		Box.soulposition = Box.history[Box.button_choice][1]
	Box.soul_choice(Vector2.ZERO)
	Box.set_options()
	Box.Screens[Box.State.Acting].show()

func input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Box.backout()
	if event.is_action_pressed("ui_accept"):
		Box.change_state(Box.State.Blittering)
		Box.blitter_act()
		await Box.BlitterText.finished_all_texts
		Box.act.emit(Box.current_target_id, Box.soulpos_to_id(Box.soulposition))
		


func _on_lose_control() -> void:
	Box.history[Box.button_choice][1] = Box.soulposition
	Box.Screens[Box.State.Acting].hide()
	
