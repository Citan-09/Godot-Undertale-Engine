extends CanvasLayer

@onready var defsize = $Control.size
var soulpos :int = 0
var saved := false
@onready var sc = get_tree().current_scene

signal _on_saved

func _ready():
	_on_saved.connect(get_tree().current_scene._on_saved)
	if "world_name" in sc:
		$Control/Texts/Location.text = sc.world_name
	else:
		$Control/Texts/Location.text = "ROOM HAS NO NAME."
	$Control.size.y = 0
	$Control.modulate.a = 0
	refresh()

func _unhandled_input(event):
	if event.is_action_pressed("ui_right") and soulpos < 1:
		$choice.play()
		soulpos += 1
		$Control/Options/Soul.position = $Control/Options/Return.position
	if event.is_action_pressed("ui_left") and soulpos > 0:
		$choice.play()
		soulpos -= 1
		$Control/Options/Soul.position = $Control/Options/Save.position
	if event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		if saved:
			set_process_unhandled_input(false)
			await _hide()
			queue_free()
		else:
			if soulpos:
				await _hide()
				queue_free()
			else:
				_on_saved.emit()
				saved = true
				$Control/Options/Return.hide()
				$Control/Options/Save.text = "[color=yellow]Saved."
				$Control/Options/Soul.hide()
				Global.savegame()
				refresh()
			$save.play()

func _hide():
	Global.player_in_menu = false
	var tw = create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tw.tween_property($Control,"size:y",0.0,0.6)
	tw.tween_property($Control,"modulate:a",0,0.6)
	await tw.finished

func refresh():
	$Control/Texts/Name.text = Global.player_name
	$Control/Texts/Lv.text = "LV%s" % [Global.player_lv]
	var timetext =  Time.get_time_string_from_unix_time(Global.cache_playtime)
	$Control/Texts/Time.text = timetext
	if "world_name" in sc:
		Global.overworld_data["room_name"] = sc.world_name
	else:
		Global.overworld_data["room_name"] = "ROOM HAS NO NAME."

func _show():
	Global.player_in_menu = true
	var tw = create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tw.tween_property($Control,"size:y",defsize.y,0.6)
	tw.tween_property($Control,"modulate:a",1,0.6)
	
