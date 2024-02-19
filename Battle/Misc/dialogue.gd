extends Control
class_name DialogueControl

@export var custom_character: EnemySpeech.characters
@onready var bubble_text: EnemySpeech = $TextContainer/Text
signal set_expression(expressions: Array[int])

func _ready() -> void:
	bubble_text.text = ""
	modulate.a = 0
	bubble_text.current_character = custom_character
	bubble_text.character_customize()


##exp_arr is a nested array where you can get an array of values for each line (useful for sans shrugging and stuff)
func DialogueText(dialogues: Dialogues) -> void:
	bubble_text.text = ""
	await create_tween().tween_property(self, "modulate:a", 1, 0.1).finished
	bubble_text.type_text_advanced.call_deferred(dialogues)
	await bubble_text.finished_all_texts
	create_tween().tween_property(self, "modulate:a", 0, 0.1)




func _on_text_expression_set(expr: Array[int]) -> void:
	set_expression.emit(expr)
