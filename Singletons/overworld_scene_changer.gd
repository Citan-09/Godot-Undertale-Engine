extends Node

@export_file("*.tscn") var default_scene: String
@onready var Camera: CameraFx
var overworld_scene: Overworld

const DEFAULT_BATTLE := "res://Battle/battle.tscn"

const blind_time: float = 0.4

var data := {
	entrance = null,
	direction = Vector2i.DOWN,
}

var data_default := data.duplicate()



func enter_room_default() -> void:
	Global.overworld_data.room = default_scene
	_prepare_enter_room()


func _prepare_enter_room() -> void:
	await Camera.blind(blind_time, 1)
	_load_and_set_scene(default_scene)


func enter_room_path(room_path: String, extra_data: Dictionary = {}) -> void:
	data.merge(extra_data, true)
	_prepare_enter_room()

func _load_and_set_scene(path: String) -> void:
	var resource: PackedScene
	if ResourceLoader.exists(path):
		resource = load(path)
	else:
		resource = load(default_scene)
	if !resource is PackedScene:
		Global.overworld_data.room = default_scene
		resource = load(default_scene)
	else:
		Global.overworld_data.room = path
	Global.scene_container.change_scene_to_packed(resource)

	_set_player_data.call_deferred(Global.scene_container.current_scene)


func _set_player_data(current_scene: Node) -> void:
	if current_scene is Overworld:
		current_scene.room_init(data)
	Global.player_can_move = true
	Global.player_in_menu = false
	data = data_default.duplicate()
	Camera.blind(0, blind_time)


func load_cached_overworld_scene(transistion := true) -> void:
	await _scene_setup_thing(transistion)
	var tree := Global.scene_container
	tree.unload_current_scene()
	var sc: Node = overworld_scene if overworld_scene else (load(default_scene) as PackedScene).instantiate()
	tree.current_scene = sc
	tree.MainViewport.add_child(sc)
	sc.request_ready()


func load_battle(
				battle_scene_path: String = DEFAULT_BATTLE,
				battle_resource: Encounter = preload("res://Resources/Encounters/EncounterTest.tres"),
				transistion := true, to_position := Vector2(48, 452)
			) -> void:
	var tree := Global.scene_container
	var screen: BattleTransistion
	if transistion:
		screen = preload("res://Overworld/battle_transistion.tscn").instantiate()
		screen.target = to_position
		tree.current_scene.add_child(screen)
		await screen.transistion()
	Global.player_in_menu = false
	Global.player_can_move = true
	var battle: Node = (load(battle_scene_path) as PackedScene).instantiate()
	battle.encounter = battle_resource
	overworld_scene = tree.current_scene
	tree.MainViewport.remove_child(overworld_scene)
	tree.current_scene = battle
	tree.MainViewport.add_child(battle)


func _scene_setup_thing(transistion: bool) -> void:
	Global.player_in_menu = false
	Global.player_can_move = true
	if transistion:
		Camera.blind(1, blind_time)
		Camera.finished_tween.connect(Camera.blind.bind(0, blind_time), CONNECT_ONE_SHOT)
		await Camera.finished_tween


func load_general_scene(scene_path: String, transistion := true):
	await _scene_setup_thing(transistion)
	var tree := Global.scene_container
	var scene: Node = (load(scene_path) as PackedScene).instantiate()
	overworld_scene = tree.current_scene
	tree.MainViewport.remove_child(overworld_scene)
	tree.current_scene = scene
	tree.MainViewport.add_child(scene)
	

