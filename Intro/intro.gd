extends Control

@onready var Camera: CameraFx = $Camera


func _ready() -> void:
	@warning_ignore("redundant_await")
	await _play_intro()
	await Camera.blind(0.6, 1)
	if Global.first:
		get_tree().change_scene_to_file("res://Intro/name_selection.tscn")
	else:
		get_tree().change_scene_to_file("res://Menus/save_loader.tscn")


func _play_intro() -> void:
	pass  # Replace with actual Intro

