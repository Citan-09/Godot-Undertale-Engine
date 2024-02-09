extends Camera2D
class_name CameraFx

@onready var blinder: ColorRect = $CanvasLayer/Blinder
@onready var glitcher: ColorRect = $Glitch/Glitch
@onready var VFX: Array[CanvasItem] = [
	$Glitch/Glitch
]
var blindertween: Tween

@export var shake_amounts: Array = [32.0, 32.0, 10.0]
@export var noise: FastNoiseLite
var counter: float = 0.0
var shakeamt: float = 0.0

var glitchtween: Tween

signal finishedtween(type: TweenType)

enum TweenType {
	Blind,
	Glitch,
}

func blind(time: float = 0, targetopacity: float = 1) -> void:
	blindertween = create_tween().set_trans(Tween.TRANS_SINE)
	blindertween.tween_property(blinder, "modulate:a", targetopacity, time)
	await blindertween.finished
	emit_signal("finishedtween", TweenType.Blind)


func glitch(time: float = 0, targetrate: float = 1) -> void:
	glitchtween = create_tween().set_parallel()
	glitchtween.tween_property(glitcher.material, "shader_parameter/shake_power", targetrate * 0.1, time)
	glitchtween.tween_property(glitcher.material, "shader_parameter/shake_color_rate", targetrate * 0.01, time)
	await glitchtween.finished
	emit_signal("finishedtween", TweenType.Glitch)

func rgbsplit(time: float = 0, targetrate: float = 1) -> void:
	glitchtween = create_tween().set_parallel()
	glitchtween.tween_property(glitcher.material, "shader_parameter/shake_color_rate", targetrate * 0.01, time)
	await glitchtween.finished
	emit_signal("finishedtween", TweenType.Glitch)

var vfx: bool = Global.settings.vfx

func _process(_delta: float) -> void:
	if shakeamt > 0.0 and Global.settings["shake"]:
		shakeamt = lerpf(shakeamt, 0, 0.13)
		if shakeamt < 0:
			shakeamt = 0
		shake()
	if Global.settings.vfx != vfx:
		vfx = Global.settings.vfx
		for i in VFX:
			i.visible = vfx

func add_shake(amt: float = 0.1) -> void:
	shakeamt += amt

func shake() -> void:
	counter += 1.0
	offset.x = noise.get_noise_2d(noise.seed * 1.29, counter) * shake_amounts[0] * shakeamt
	offset.y = noise.get_noise_2d(noise.seed * 5.822, counter) * shake_amounts[1] * shakeamt
	rotation_degrees = noise.get_noise_2d(noise.seed * 6.20, counter) * shake_amounts[2] * shakeamt

