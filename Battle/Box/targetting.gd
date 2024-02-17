extends BattleBoxBehaviour


func _on_gain_control() -> void:
	if Box.history[Box.button_choice][0]:
		Box.soulposition = Box.history[Box.button_choice][0]
	Box.soul_choice(Vector2.ZERO)
	Box.choicesextends.resize(Box.enemies.size())
	Box.Screens[Box.State.TargetEnemy].show()
	Box.choicesextends.fill(1)
	Box.set_targets(false if Box.button_choice else true)

func input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Box.backout()
		Box.moved_to_buttons.emit()
	if event.is_action_pressed("ui_accept"):
		if Box.button_choice == Box.OPTION_FIGHT:
			Box.change_state(Box.State.Fighting)
		elif Box.button_choice == Box.OPTION_ACT:
			Box.change_state(Box.State.Acting)
		elif Box.button_choice == Box.OPTION_MERCY:
			Box.change_state(Box.State.Mercying)
	return


func _on_lose_control() -> void:
	Box.current_target_id = Box.soulpos_to_id(Box.soulposition, 1)
	Box.history[Box.button_choice][0] = Box.soulposition
	Box.Screens[Box.State.TargetEnemy].hide()
