extends AnimatedSprite2D
class_name SavePoint

var txt_box = preload("res://Overworld/text_box.tscn")
var _save = preload("res://Overworld/save_menu.tscn")

@export var save_text :Array[String]= ["* DETERMINATION!!!"]

func _ready():
	save_text.append("* (HP Fully restored.)")

func _on_interact_save():
	Global.heal(100000)
	var textbox = txt_box.instantiate() as TextBox
	get_tree().current_scene.add_child(textbox)
	await textbox.generic(save_text)
	var save_menu = _save.instantiate()
	get_tree().current_scene.add_child(save_menu)
	save_menu._show()
	
