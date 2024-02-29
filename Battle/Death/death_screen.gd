extends Node2D
class_name DeathScreen

@onready var Camera: CameraFx = Global.scene_container.Camera

var tw: Tween

func _ready() -> void:
	Global.Music.stop()
	Global.load_game()
	Global.overworld_temp_data["global_position"] = null
	Global.flags = Global.flags_at_save
	AudioPlayer.play("hurt")
	Camera.add_shake(0.3)
	$DeathSoul.position = Global.player_position
	tw = create_tween().set_trans(Tween.TRANS_QUAD).set_parallel()
	tw.tween_interval(0.4)
	tw.chain().tween_property(Camera, "zoom", Vector2.ONE * 3, 0.4).set_ease(Tween.EASE_IN).set_delay(0.4)
	tw.tween_property(Camera, "position", $DeathSoul.position, 0.4).set_ease(Tween.EASE_OUT)
	tw.chain().tween_callback($DeathSoul.die).set_delay(0.3)
	tw.tween_property($Fade/RichTextLabel, "modulate:a", 1, 0.5).set_ease(Tween.EASE_OUT).set_delay(3)
	tw.tween_callback($mus.play).set_delay(2.8)
	tw.tween_property($mus, "volume_db", 0, 0.4).set_delay(2.8)

var pressed := false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and !pressed:
		_done()

func _done() -> void:
	tw.kill()
	pressed = true
	Global.just_died = true
	OverworldSceneChanger.enter_room_path(Global.overworld_data.room if Global.overworld_data.room is String else OverworldSceneChanger.default_scene, {})
