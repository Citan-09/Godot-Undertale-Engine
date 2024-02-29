extends Node2D
class_name Overworld

@export var world_name := "overworld room"
@export var player_path := ^"YSortNodes/TileMap/PlayerOverworld"
#@export var camera_path := ^"YSortNodes/TileMap/PlayerOverworld/Camera"
#@export var music_player := ^"music"
@export var music: AudioStream = preload("res://Musics/default2.wav")
@export var room_entrances: Array[RoomEntranceNode] = []
@onready var Player: PlayerOverworld = get_node(player_path)
@onready var Camera: CameraFx = Global.scene_container.Camera
@onready var Music: AudioStreamPlayer = Global.Music #get_node(music_player)

var text_box: PackedScene = preload("res://Overworld/text_box.tscn")

#var data := {
	#
#}

func _on_saved() -> void:
	Global.overworld_data["room_pos"] = [Player.global_position.x, Player.global_position.y]


func ready() -> void:
	pass


func _ready() -> void:
	ready()
	Camera.blinder.modulate.a = 1
	Camera.blind(0.5, 0)
	var music_tween := get_tree().create_tween()
	Music.stream = music
	Music.play()
	Music.volume_db = -70
	music_tween.tween_property(Music, "volume_db", 0, 1).set_trans(Tween.TRANS_QUAD)

func room_init(data: Dictionary) -> void:
	if data.entrance == null:
		if Global.overworld_data.get("room_pos",[0.0, 0.0]) == [0.0, 0.0] or !Global.just_died:
			return
		Player.global_position = Vector2(Global.overworld_data["room_pos"][0], Global.overworld_data["room_pos"][1])
		Global.just_died = false
		return
	## Finding entrances
	for room in room_entrances:
		if room.door_id != data.entrance:
			continue
		Player.position = room.position + room.size / 2.0 + room.facing_direction * room.door_margin
		Player.force_direction(room.facing_direction)
		break
	
	
	
	#if Global.overworld_temp_data.get("global_position"):
		#Player.global_position = Global.overworld_temp_data["global_position"]
		#Global.overworld_temp_data["global_position"] = Vector2.ZERO


func summontextbox() -> TextBox:
	var clone: Node = text_box.instantiate()
	add_child(clone)
	return clone

