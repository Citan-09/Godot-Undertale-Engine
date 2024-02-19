@tool
extends Resource
class_name Dialogue

@export_multiline var dialog_text: String = "test"
@export var dialog_expressions: Array[int] = [0,0]

@export var pauses: Array[DialoguePause] = []


enum PauseType{
	CHAR,
	INDEX_LIST,
}



