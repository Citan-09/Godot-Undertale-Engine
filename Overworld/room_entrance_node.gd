class_name RoomEntranceNode extends ReferenceRect


@export var facing_direction := Vector2.ZERO
@export var door_id: int = 0
@export var door_margin: int = 16

@export_group("Entered Room")
@export_file("*.tscn") var new_room := "res://Overworld/overworld_default.tscn"
@export var special_room := false
@export var new_room_entrance_id: int = 0 


@onready var Area: OverworldAreaTrigger = preload("res://Overworld/Interactions/area_trigger.tscn").instantiate() as OverworldAreaTrigger

func force_enter() -> void:
	Area._successful_enter()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	facing_direction = facing_direction.normalized()
	Area.action = 19 if special_room else 3
	Area.new_room = new_room
	Area.new_room_entrance = new_room_entrance_id
	add_child(Area, true, Node.INTERNAL_MODE_FRONT)
	Area.scale = size / 20.0
	Area.position = size / 2.0


