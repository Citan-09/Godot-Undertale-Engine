extends BattleBoxBehaviour


func _on_gain_control():
	if !Global.items.size() > 0:
		Box.moved_to_buttons.emit()
		return
	if Box.history[Box.button_choice][0]:
		Box.soulposition = Box.history[Box.button_choice][0]
		Box.soul_choice(Vector2.ZERO)
	Box.set_items()
	Box.Screens[Box.State.Iteming].show()


func input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down"):
		Box.set_items.call_deferred()
	if event.is_action_pressed("ui_cancel"):
		Box.backout()
		Box.moved_to_buttons.emit()
	if event.is_action_pressed("ui_accept"):
		if !Global.items.size() > 0:
			Box.moved_to_buttons.emit()
			return
		Box.change_state(Box.State.Blittering)
		Box.used_item = Global.items[Box.soulpos_to_id(Box.soulposition, 1)]
		Box.blitter_item()
		await Box.BlitterText.finished_all_texts
		Box.item.emit(Box.used_item)
	return


func _on_lose_control() -> void:
	Box.history[Box.OPTION_ITEM][0] = clamp(Box.soulposition, Vector2i.ZERO, (Global.items.size() - 1) * Vector2i.DOWN)
	Box.Screens[Box.State.Iteming].hide()
	
	
