extends RemoteTransform2D
class_name CameraRemoteController


func _set_limits() -> void:
	Global.scene_container.Camera.limit_left = limit_left
	Global.scene_container.Camera.limit_top = limit_top
	Global.scene_container.Camera.limit_right = limit_right
	Global.scene_container.Camera.limit_bottom = limit_bottom

@export var zoom := Vector2.ONE
@export var position_smoothing_enabled := true

@export var limit_left: int =  -10000000000000
@export var limit_top: int =   -10000000000000
@export var limit_right: int =  10000000000000
@export var limit_bottom: int = 10000000000000



func _ready() -> void:
	Global.scene_container.Camera.position_smoothing_enabled = position_smoothing_enabled
	remote_path = get_path_to(Global.scene_container.Camera, true)
	_set_limits()
	pass

func _process(delta: float) -> void:
	Global.scene_container.Camera.zoom = zoom


func add_shake(amt: float) -> void:
	Global.scene_container.Camera.add_shake(amt)
