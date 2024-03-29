extends AnimatedSprite2D
class_name SavePoint

var txt_box: PackedScene = preload("res://Overworld/text_box.tscn")
var _save: PackedScene = preload("res://Overworld/save_menu.tscn")

@export var save_text: Array[String] = ["* DETERMINATION!!!"]

func _ready() -> void:
	save_text.append("* (HP Fully restored.)")

func _on_interact_save() -> void:
	Global.heal(100000)
	var textbox := txt_box.instantiate() as TextBox
	Global.scene_container.current_scene.add_child(textbox)
	await textbox.generic(Dialogues.new().from(save_text))
	var save_menu: Node = _save.instantiate()
	Global.scene_container.current_scene.add_child(save_menu)

