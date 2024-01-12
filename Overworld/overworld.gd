extends Node2D
class_name Overworld

@export var world_name := "overworld room"
@export var player_path := ^"YSortNodes/TileMap/PlayerOverworld"
@export var camera_path := ^"YSortNodes/TileMap/PlayerOverworld/Camera"
@onready var Player :PlayerOverworld = get_node(player_path)
@onready var Camera = get_node(camera_path)

var text_box = preload("res://Overworld/text_box.tscn")

func _on_saved():
	Global.overworld_data["room_pos"] = [Player.global_position.x,Player.global_position.y]


func _notification(what):
	if what == NOTIFICATION_READY:
		Camera.blinder.modulate.a = 1
		Camera.blind(0.5,0)
		if Global.overworld_data["room_pos"] != [0.0,0.0]:
			Player.global_position = Vector2(Global.overworld_data["room_pos"][0],Global.overworld_data["room_pos"][1])
		if Global.overworld_temp_data["global_position"]:
			Player.global_position =  Global.overworld_temp_data["global_position"]
			Global.overworld_temp_data["global_position"] = Vector2.ZERO
			

func summontextbox() -> TextBox:
	var clone = text_box.instantiate()
	add_child(clone)
	return clone

## Loads a battle and saves some overworld data
func load_battle_save_data(battle_scene_path:String = "res://Battle/battle.tscn",battle_name = "defaultbattle",transistion := true,to_position := Vector2(48,452)):
	Global.overworld_temp_data = {"global_position" : Player.global_position}
	await Global.load_battle()
