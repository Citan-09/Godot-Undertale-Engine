extends Area2D
class_name OverworldAreaTrigger

@export var required_collider_group := ""
@export_category("Actions")
@export_flags("ROOM_CHANGE", "STOP_MOVEMENT", "CUTSCENE", "ONE_SHOT", "SPECIAL") var action: int = 0
@export var entrance_direction := Vector2.DOWN
@export_subgroup("ROOM_CHANGE")
@export_file("*.tscn") var new_room := "res://Overworld/overworld_default.tscn"
## For the NEW room.
@export var room_entrance: int = -1


signal cutscene
signal stopped_obj

signal finished_work

func _ready() -> void:
	$Collision.debug_color = Color(randf(), randf(), randf(), 0.35)


func _on_obj_entered(body: Node) -> void:
	if !required_collider_group or body.is_in_group(required_collider_group):
		if body is PlayerOverworld:
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
					await get_tree().create_timer(OverworldSceneChanger.blind_time - 0.06, false).timeout
					body.position += entrance_direction * 10
					body.force_direction(entrance_direction)
				else:
					OverworldSceneChanger.enter_room_path(new_room, {
						"entrance": room_entrance,
						"direction": -body.direction
					})
				if action & 8: finished_work.emit()
		elif "canmove" in body:
			stopped_obj.emit()
			body.canmove = false
			if action & 8: finished_work.emit()
		


func disable() -> void:
	set_deferred("monitorable",false)
	set_deferred("monitoring",false)
	$Collision.set_deferred("disabled",true)

