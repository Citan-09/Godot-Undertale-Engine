class_name SceneContainer extends Control


@onready var SettingsViewportContainer: SubViewportContainer = $SettingsContainer
@onready var MainViewportContainer: SubViewportContainer = $SubViewportContainer
@onready var MainViewport: SubViewport = $SubViewportContainer/MainViewport
@onready var Camera: CameraFx = %GlobalCamera:
	set(cam):
		Camera = cam
		OverworldSceneChanger.Camera = Camera
@onready var Border: NinePatchRect = $SettingsContainer/Border
@onready var ScreenCopy: TextureRect = $ScreenCopy



var current_scene: Node: set = set_current_scene

const default_scene: String = "res://Intro/intro.tscn"
const camera_scene: PackedScene = preload("res://Camera/camera_advanced.tscn")

func set_current_scene(scene: Node) -> void:
	current_scene = scene
	reload_camera()



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init_camera()
	Global.scene_container = self
	Global.fullscreen_toggled.connect(_on_fullscreen_toggle)
	change_scene_to_file(default_scene)
	_on_settings_setting_changed("border", Global.settings.get("border", true))
	
const SCREEN_SIZE := Vector2(640, 480)

func change_scene_to_file(path: String) -> Error:
	if !ResourceLoader.exists(path):
		return ERR_INVALID_PARAMETER
	var scene_resource = (load(path) as PackedScene)
	if !scene_resource:
		return ERR_INVALID_DATA
	return change_scene_to_packed(scene_resource)
	

func change_scene_to_packed(file: PackedScene) -> Error:
	unload_current_scene()
	var scene: Node = file.instantiate() as Node
	current_scene = scene
	MainViewport.add_child(scene)
	return OK
	

func unload_current_scene() -> void:
	if !current_scene:
		return
	current_scene.get_parent().remove_child(current_scene)
	current_scene.queue_free()
	current_scene = null


func reload_current_scene() -> void:
	if !current_scene:
		return
	change_scene_to_file(current_scene.scene_file_path)


func reload_camera() -> void:
	MainViewport.remove_child(Camera)
	Camera.queue_free()
	Camera = camera_scene.instantiate()
	MainViewport.add_child(Camera)
	Camera.name = "GlobalCamera"
	Camera.unique_name_in_owner = true
	init_camera()


func init_camera() -> void:
	Camera.position = Vector2(320, 240)
	Camera.reset_smoothing()


func get_fullscreeen_scale() -> int:
	var sc_size: Vector2i = DisplayServer.screen_get_size()
	return min(floor(sc_size.x / SCREEN_SIZE.x), floor(sc_size.y / SCREEN_SIZE.y))


func _on_fullscreen_toggle(to: bool) -> void:
	MainViewportContainer.scale = Vector2.ONE * (get_fullscreeen_scale() if to else 1)
	SettingsViewportContainer.scale = MainViewportContainer.scale
	if _just_toggled_border: _refresh_window()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _refresh_window() -> void:
	_just_toggled_border = false
	var to: bool = Global.settings.get("border", true)
	get_window().size = Vector2(
		ProjectSettings.get("display/window/size/viewport_width"),
		ProjectSettings.get("display/window/size/viewport_height")
	) if to else SCREEN_SIZE
	get_window().move_to_center()


var _just_toggled_border := false

func _on_settings_setting_changed(setting_name: String, to: Variant) -> void:
	match setting_name.to_lower():
		"border":
			_refresh_window()
			_just_toggled_border = true
			Border.visible = to
			ScreenCopy.visible = to
			if Global.fullscreen:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	


