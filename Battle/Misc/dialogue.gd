extends Control

@export var custom_character: EnemySpeech.characters
@onready var bubble_text: EnemySpeech = $TextContainer/Text
#var expression_array := []
signal set_head(head_id: int)

func _ready() -> void:
	bubble_text.text = ""
	modulate.a = 0
	bubble_text.current_character = custom_character
	bubble_text.character_customize()

##exp_arr is a nested array where you can get an array of values for each line (useful for sans shrugging and stuff)
func DialogueText(text: Array, exp_arr: Array):
	#expression_array = exp_arr
	bubble_text.text = ""
	await create_tween().tween_property(self, "modulate:a", 1, 0.1).finished
	bubble_text.typetext(text)
	for i in exp_arr.size():
		var exp = await bubble_text.startedtyping
		#_set_expression(exp_arr[exp])
		set_head.emit(exp_arr[exp])
	await bubble_text.finishedalltexts
	create_tween().tween_property(self, "modulate:a", 0, 0.1)


