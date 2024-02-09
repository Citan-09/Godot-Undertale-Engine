extends CanvasLayer

@onready var defsize: Vector2 = $Control.size
var soulpos: int = 0
var saved := false
@onready var sc: Node = get_tree().current_scene

signal _on_save
var tw: Tween

func _ready() -> void:
	var c_scene: Node = get_tree().current_scene
	if "_on_saved" in c_scene: _on_save.connect(c_scene._on_saved)
	if "world_name" in sc:
		$Control/Texts/Location.text = sc.world_name
	else:
		$Control/Texts/Location.text = "ROOM HAS NO NAME."
	$Control.modulate.a = 0
	_show()
	refresh()

func _unhandled_input(event: InputEvent) -> void:
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
				_on_save.emit()
				saved = true
				$Control/Options/Return.hide()
				$Control/Options/Save.text = "[color=yellow]Saved."
				$Control/Options/Soul.hide()
				Global.savegame()
				refresh()
				$save.play()

func _show() -> void:
	Global.player_in_menu = true
	tw = create_tween().set_parallel().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property($Control, "modulate:a", 1, 0.2)


func _hide() -> void:
	Global.player_in_menu = false
	tw = create_tween().set_parallel().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property($Control, "modulate:a", 0, 0.2)
	await tw.finished

func refresh() -> void:
	$Control/Texts/Name.text = Global.player_name
	$Control/Texts/Lv.text = "LV%s" % [Global.player_lv]
	@warning_ignore("narrowing_conversion")
	var timetext := Time.get_time_string_from_unix_time(Global.cache_playtime)
	$Control/Texts/Time.text = timetext
	if "world_name" in sc:
		Global.overworld_data["room_name"] = sc.world_name
	else:
		Global.overworld_data["room_name"] = "ROOM HAS NO NAME."


