extends CanvasLayer

@onready var defsize: Vector2 = $Control.size
var soulpos: int = 0
var saved := false
@onready var sc: Node = get_tree().current_scene

signal _on_save
signal choiced
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
	if event.is_action_pressed("ui_accept") and saved or event.is_action_pressed("ui_cancel"):
		dismiss()
		get_viewport().set_input_as_handled()
	

func dismiss() -> void:
	choiced.emit()
	set_process_unhandled_input(false)
	await _hide()
	queue_free()


func save() -> void:
	choiced.emit()
	_on_save.emit()
	saved = true
	$Control/Options/Return.hide()
	$Control/Options/Save.text = "[color=yellow]Saved."
	$Control/Options/Soul.hide()
	Global.save_game()
	refresh()
	AudioPlayer.play("save")

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
	var timetext := Time.get_time_string_from_unix_time(Global.cache_playtime)
	$Control/Texts/Time.text = timetext
	if "world_name" in sc:
		Global.overworld_data["room_name"] = sc.world_name
	else:
		Global.overworld_data["room_name"] = "ROOM HAS NO NAME."


