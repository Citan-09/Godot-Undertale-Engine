extends Area2D
class_name OverworldAreaTrigger

@export var camera_path: NodePath = ^"/root/overworld/Camera"
@export var required_collider_tag := ""
@export_category("Actions")
@export_flags("ROOM_CHANGE", "STOP_MOVEMENT", "CUTSCENE", "ONE_SHOT") var action = 0
@export_subgroup("ROOM_CHANGE")
@export_file("*.tscn") var new_room = "res://Overworld/overworld_default.tscn"
## For the NEW room.
@export var room_entrance: int = 0

signal cutscene
signal stopped_obj
func _ready():
	$Collision.debug_color = Color(randf(), randf(), randf(), 0.35)


func _on_obj_entered(body: Node):
	if !required_collider_tag or body.is_in_group(required_collider_tag):
		if action & 4 and body.is_in_group("player"):
			connect("cutscene", queue_free)
			cutscene.emit()
		if action & 2:
			if body.is_in_group("player"):
				Global.player_can_move = false
			elif "canmove" in body:
				stopped_obj.emit()
				body.canmove = false
		if action & 1 and body.is_in_group("player"):
			await get_node(camera_path).blind(0.5, 1.5)
			if action & 2: Global.player_can_move = true
			Global.overworld_temp_data["room_entrance"] = room_entrance
			get_tree().change_scene_to_packed(load(new_room))




