extends Control
class_name DialogueControl

@export var custom_character: EnemySpeech.characters
@onready var bubble_text: EnemySpeech = $TextContainer/Text
signal set_head(expressions: Variant)

func _ready() -> void:
	bubble_text.text = ""
	modulate.a = 0
	bubble_text.current_character = custom_character
	bubble_text.character_customize()


##exp_arr is a nested array where you can get an array of values for each line (useful for sans shrugging and stuff)
func DialogueText(text: Array, exp_arr: Array) -> void:
	bubble_text.text = ""
	await create_tween().tween_property(self, "modulate:a", 1, 0.1).finished
	bubble_text.type_text.call_deferred(text)
	for i in exp_arr.size():
		var expr: int = await bubble_text.started_typing
		set_head.emit(exp_arr[expr])
	await bubble_text.finished_all_texts
	create_tween().tween_property(self, "modulate:a", 0, 0.1)


