extends Area2D
class_name OverworldAreaTrigger

@export var required_collider_group := ""
@export_category("Actions")
@export_flags("ROOM_CHANGE", "STOP_MOVEMENT", "CUTSCENE", "ONE_SHOT") var action = 0
@export_subgroup("ROOM_CHANGE")
@export_file("*.tscn") var new_room = "res://Overworld/overworld_default.tscn"
## For the NEW room.
@export var room_entrance: int = -1

signal cutscene
signal stopped_obj

signal finished_work

func _ready():
	$Collision.debug_color = Color(randf(), randf(), randf(), 0.35)

func _on_obj_entered(body: Node):
	if !required_collider_group or body.is_in_group(required_collider_group):
		if action & 2:
			if body is PlayerOverworld:
				if action & 4:
					cutscene.emit()
				Global.player_can_move = false
			elif "canmove" in body:
				stopped_obj.emit()
				body.canmove = false
		if action & 1 and body is PlayerOverworld:
			if action & 2: Global.player_can_move = true
			OverworldSceneChanger.enter_room_path(new_room, {
				"entrance": room_entrance,
				"direction": -body.direction
			})
		finished_work.emit()


func disable():
	set_deferred("monitorable",false)
	set_deferred("monitoring",false)
	$Collision.set_deferred("disabled",true)

