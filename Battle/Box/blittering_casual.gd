extends BattleBoxBehaviour

func _on_gain_control() -> void:
	Box.Screens[Box.State.BlitteringCasual].show()




func _on_lose_control() -> void:
	Box.Screens[Box.State.BlitteringCasual].hide()
	print("Blitter visible is ", Box.Screens[Box.State.Blittering].visible)

