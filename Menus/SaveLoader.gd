extends CanvasLayer

@onready var defsize = $Control.size
var soulpos: int = 0
var reset := false
func _ready():
	$Control/Texts/Location.text = Global.overworld_data["room_name"]
	refresh()

func _unhandled_input(event):
	if event.is_action_pressed("ui_right") and soulpos < 1:
		$choice.play()
		soulpos += 1
		$Control/Options/Soul.position = $Control/Options/Reset.position
	if event.is_action_pressed("ui_left") and soulpos > 0:
		$choice.play()
		soulpos -= 1
		$Control/Options/Soul.position = $Control/Options/Load.position
	if event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		if soulpos:
			if reset:
				set_process_unhandled_input(false)
				Global.resetgame()
				var tw = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
				tw.tween_property($Control, "position:y", 640, 0.7).as_relative()
				await tw.finished
				await get_tree().create_timer(0.4, false).timeout
				get_tree().change_scene_to_file(ProjectSettings.get("application/run/main_scene"))
			else:
				$warn.play()
				$Control/Options/Reset.text = "[color=red]CONFIRM RESET"
				reset = true
		else:
			get_tree().change_scene_to_file("res://Overworld/overworld_room_loader.tscn")

func _hide():
	Global.player_in_menu = false
	var tw = create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tw.tween_property($Control, "size:y", 0.0, 0.6)
	tw.tween_property($Control, "modulate:a", 0, 0.6)
	await tw.finished

func refresh():
	$Control/Texts/Name.text = Global.player_name
	$Control/Texts/Lv.text = "LV%s" % [Global.player_lv]
	var timetext = Time.get_time_string_from_unix_time(Global.cache_playtime)
	$Control/Texts/Time.text = timetext

func _show():
	Global.player_in_menu = true
	var tw = create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tw.tween_property($Control, "size:y", defsize.y, 0.6)
	tw.tween_property($Control, "modulate:a", 1, 0.6)

