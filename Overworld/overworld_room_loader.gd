extends Node
class_name OverworldRoomLoader

@export var rooms = [
	"res://Overworld/overworld_default.tscn"
]

func _ready():
	var room = Global.overworld_data.get("room")
	get_tree().change_scene_to_packed.call_deferred(rooms[room] if room and room >= 0 and room < rooms.size() else preload("res://Overworld/overworld_default.tscn"))
