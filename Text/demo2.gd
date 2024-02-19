extends AdvancedTextTyper

@export var dialogue: Dialogues

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	type_text_advanced(dialogue)
