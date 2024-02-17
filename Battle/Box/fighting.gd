extends BattleBoxBehaviour



func _on_gain_control() -> void:
	Box.exit_menu.emit()
	Box.fight.emit(Box.current_target_id)
	




func _on_lose_control() -> void:
	pass
