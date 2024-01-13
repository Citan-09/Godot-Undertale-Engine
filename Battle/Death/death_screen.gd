extends Node2D
class_name DeathScreen

@onready var Camera: CameraFx = $Camera

func _ready():
	Global.loadgame()
	Global.overworld_temp_data["global_position"] = null
	Global.flags = Global.flags_at_save
	$hurt.play()
	Camera.add_shake(1)
	$DeathSoul.position = Global.player_position
	await get_tree().create_timer(0.4, false).timeout
	var tw = create_tween().set_trans(Tween.TRANS_QUAD).set_parallel()
	tw.tween_property(Camera, "zoom", Vector2.ONE * 3, 0.4).set_ease(Tween.EASE_IN).set_delay(0.2)
	tw.tween_property(Camera, "position", $DeathSoul.position, 0.4).set_ease(Tween.EASE_OUT)
	await tw.finished
	await get_tree().create_timer(0.3, false).timeout
	await $DeathSoul.die()
	tw = create_tween().set_trans(Tween.TRANS_QUAD).set_parallel()
	tw.tween_property($Fade/RichTextLabel, "modulate:a", 1, 0.3).set_ease(Tween.EASE_OUT)
	await Confirm
	await Camera.blind(0.6, 1)
	Global.just_died = true
	get_tree().change_scene_to_file("res://Overworld/overworld_room_loader.tscn")

signal Confirm

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"): Confirm.emit()
