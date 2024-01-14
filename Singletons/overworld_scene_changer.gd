extends Node

@export_file("*.tscn") var default_scene: String
@onready var Blinder = $Blinder

const blind_time: float = 0.5

var data = {
	entrance = null,
	direction = Vector2i.DOWN,
}

var data_default = data.duplicate()

func _ready() -> void:
	Blinder.modulate.a = 0

func enter_room_default():
	Global.overworld_data.room = default_scene
	var tw = create_tween().set_trans(Tween.TRANS_QUAD)
	tw.tween_property(Blinder,"modulate:a",1,blind_time)
	await tw.finished
	_load_and_set_scene(default_scene)

	
func enter_room_path(room_path: String, extra_data: Dictionary = {}):
	data.merge(extra_data, true)
	var tw = create_tween().set_trans(Tween.TRANS_QUAD)
	tw.tween_property(Blinder,"modulate:a",1,blind_time)
	await tw.finished
	_load_and_set_scene(room_path)

func _load_and_set_scene(path: String):
	var resource = load(path)
	if !resource is PackedScene:
		Global.overworld_data.room = default_scene
		resource = default_scene
	else:
		Global.overworld_data.room = path
	resource = resource.instantiate()
	var current_scene = get_tree().current_scene
	get_tree().unload_current_scene()
	get_tree().root.add_child(resource)
	get_tree().current_scene = resource
	
	_set_player_data(resource)

func _set_player_data(current_scene):
	if current_scene is Overworld:
		current_scene.data = data
		current_scene.room_init()
	
	data = data_default.duplicate()
	var tw = create_tween().set_trans(Tween.TRANS_QUAD)
	tw.tween_property(Blinder,"modulate:a",0,blind_time)

func load_cached_overworld_scene():
	var tree := get_tree()
	tree.unload_current_scene()
	tree.root.add_child(Global.overworld_scene)
	tree.current_scene = Global.overworld_scene

#func _ready():
	#var room = Global.overworld_data.get("room")
	#get_tree().change_scene_to_packed.call_deferred(
		#Global.rooms[room] if room and room >= 0 and room < Global.rooms.size() else preload("res://Overworld/overworld_default.tscn")
		#)
