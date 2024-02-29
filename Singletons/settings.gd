extends CanvasLayer


var tw: Tween

const TRANSTYPE := Tween.TRANS_EXPO
const TIME: float = 0.6

@onready var Darken: Panel = $Darken
@onready var Blur: CanvasItem = $Blur
@onready var BusContainer: HBoxContainer = $BusContainer
@onready var AnimPlayer: AnimationPlayer = $AnimationPlayer
@onready var BoolOptions: VBoxContainer = $BoolOptions/VBoxContainer

var enabled := false

signal setting_changed(setting_name: String, to: Variant)


func _ready() -> void:
	AnimPlayer.speed_scale = 1.0 / TIME
	Darken.modulate.a = 0
	Blur.material.set("shader_parameter/lod", 0)
	AnimPlayer.play(&"RESET")
	for setting: SettingBoolButton in BoolOptions.get_children():
		setting.pressed.connect(func():
			self.setting_changed.emit(setting.name, setting.button_pressed)
			)
		
	



func toggle() -> void:
	enabled = !enabled
	get_tree().paused = enabled
	if tw and tw.is_valid(): tw.kill()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if enabled else Input.MOUSE_MODE_HIDDEN
	tw = create_tween().set_trans(TRANSTYPE).set_ease(int(enabled) as Tween.EaseType).set_parallel()
	tw.tween_property(Blur.material, "shader_parameter/lod", int(enabled), TIME)
	tw.tween_property(Darken, "modulate:a", int(enabled), TIME)
	if enabled:
		AnimPlayer.play("toggle")
		return
	AnimPlayer.play_backwards("toggle")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_close"):
		toggle()


