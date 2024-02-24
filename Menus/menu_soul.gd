class_name MenuSoul extends Sprite2D

var tw: Tween

const TIME: float = 0.15
const TRANSTYPE := Tween.TRANS_CUBIC

func _move_to_global_position(pos: Vector2) -> void:
	if tw and tw.is_running(): tw.kill()
	tw = create_tween().set_trans(TRANSTYPE)
	tw.tween_property(self, "global_position", pos, TIME)




