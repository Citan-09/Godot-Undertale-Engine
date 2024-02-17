extends Area2D
class_name OverworldAreaTrigger

@export var required_collider_group := &""
@export_category("Actions")
@export_flags("ROOM_CHANGE", "STOP_MOVEMENT", "CUTSCENE", "ONE_SHOT", "NON_ROOM_SCENE_CHANGE") var action: int = 0
@export_subgroup("ROOM_CHANGE")
@export_file("*.tscn") var new_room := "res://Overworld/overworld_default.tscn"
## For the NEW room.
@export var new_room_entrance: int = -1


signal cutscene
signal stopped_obj

signal finished_work

func _ready() -> void:
	$Collision.debug_color = Color(randf(), randf(), randf(), 0.35)


func _on_area_entered(body: Area2D) -> void:
	_on_body_entered(body.get_parent())


func _on_body_entered(body: Node) -> void:
	if required_collider_group:
		if !body.is_in_group(required_collider_group):
			return
		stopped_obj.emit()
		if action & 2: body.canmove = false
		if action & 8: finished_work.emit()
		return
	if body.is_in_group("player"):
		_successful_enter()

func _successful_enter() -> void:
	if action & 2:
		Global.player_can_move = false
		if action & 8: finished_work.emit()
	if action & 4:
		cutscene.emit()
		if action & 8: finished_work.emit()
	if action & 1:
		Global.just_died = false
		if action & 16:
			OverworldSceneChanger.load_general_scene(new_room)
		else:
			OverworldSceneChanger.enter_room_path(new_room, {
				"entrance": new_room_entrance,
			})
			if action & 8: finished_work.emit()


func disable() -> void:
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
	$Collision.set_deferred("disabled", true)

