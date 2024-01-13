extends Node2D
class_name Overworld

@export var world_name := "overworld room"
@export var player_path := ^"YSortNodes/TileMap/PlayerOverworld"
@export var camera_path := ^"YSortNodes/TileMap/PlayerOverworld/Camera"
@export var music_player := ^"music"
@export var room_entrances: Array[Vector2] = []
@onready var Player: PlayerOverworld = get_node(player_path)
@onready var Camera = get_node(camera_path)
@onready var Music = get_node(music_player)

var text_box = preload("res://Overworld/text_box.tscn")

func _on_saved():
	Global.overworld_data["room_pos"] = [Player.global_position.x, Player.global_position.y]


func _notification(what):
	if what == NOTIFICATION_READY:
		Camera.blinder.modulate.a = 1
		Camera.blind(0.5, 0)
		if Global.overworld_data.get("room_pos",[0.0, 0.0]) != [0.0, 0.0] and Global.just_died:
			Player.global_position = Vector2(Global.overworld_data["room_pos"][0], Global.overworld_data["room_pos"][1])
			Global.just_died = false
		var room_entrance = Global.overworld_temp_data.get("room_entrance")
		if room_entrance and room_entrances.size() > room_entrance:
			Player.global_position = room_entrances[room_entrance]
			Global.overworld_temp_data["room_entrance"] = 0
		if Global.overworld_temp_data.get("global_position"):
			Player.global_position = Global.overworld_temp_data["global_position"]
			Global.overworld_temp_data["global_position"] = Vector2.ZERO
		var music_tween = create_tween()
		music_tween.tween_property(Music, "volume_db", 0, 0.5)


func summontextbox() -> TextBox:
	var clone = text_box.instantiate()
	add_child(clone)
	return clone

## Loads a battle and saves some overworld data
func load_battle_save_data(battle_scene_path: String = "res://Battle/battle.tscn", battle_resource: Encounter = preload("res://Resources/Encounters/EncounterTest.tres"), transistion := true, to_position := Vector2(48, 452)):
	Global.overworld_temp_data = {"global_position": Player.global_position}
	await Global.load_battle(battle_scene_path, battle_resource, transistion, to_position)
