@tool
extends RichTextEffect
class_name Tremble

var bbcode := "tremble"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var freq: float = char_fx.env.get("amp", 1.0) / 10.0
	var chance: float = char_fx.env.get("chance", 2)
	
	randomize()
	
	var randomBool: = bool(randi() % 101 < chance)
	var randomVector: = Vector2(randf_range( - freq, freq), randf_range( - freq, freq))
	
	if randomBool:char_fx.offset = randomVector
	return true
