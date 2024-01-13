extends Camera2D
class_name Camera2DVFX

@onready var shaders = [$vfx/glitch/glitch,$vfx/sort/sort,$vfx/vhscrt/VHSCRT,$vfx/blur/blur]
@onready var vignette = $vfx/vignette/vignette
@onready var vfx = $vfx
@onready var blinder = $ColorRect
@onready var IceOverlay = $Ice
var shakeamt = 0.0

var maxmult = 2.222

@export var IceSpeed = 3.0
@export var decay = 2.0
@export var rotate =  1.0
@export var max_offset = Vector2(64,48)
@export var power = 2
var t = 0
var noise = FastNoiseLite.new()
var degrotation = 0
var shakerotation = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	vfx.visible = Data.settings["vfxmult"]
	noise.noise_type = 0

signal faded
func blind(time = 0.8):
	var t = get_tree().create_tween().set_trans(Tween.TRANS_QUAD)
	t.tween_property(blinder,"modulate:a",1,time)
	await t.finished
	emit_signal("faded")

func unblind(time = 0.8):
	var t = get_tree().create_tween().set_trans(Tween.TRANS_QUAD)
	t.tween_property(blinder,"modulate:a",0,time)
	await t.finished
	emit_signal("faded")
	
func blur(time = 0.8,pow = 1.0):
	var t = get_tree().create_tween().set_trans(Tween.TRANS_QUAD)
	t.tween_property(shaders[3].material,"shader_parameter/lod",pow,time)
	await t.finished
	emit_signal("faded")

func unblur(time = 0.8):
	var t = get_tree().create_tween().set_trans(Tween.TRANS_QUAD)
	t.tween_property(shaders[3].material,"shader_parameter/lod",0,time)
	await t.finished
	emit_signal("faded")

func glitch(time = 0.8):
	shaders[0].show()
	var t = get_tree().create_tween().set_trans(Tween.TRANS_QUAD)
	t.tween_property(shaders[0].material,"shader_parameter/shake_color_rate",0.01,time)
	var t2 = get_tree().create_tween().set_trans(Tween.TRANS_QUAD)
	t2.tween_property(shaders[0].material,"shader_parameter/shake_power",0.03,time)

func unglitch(time = 0.8):
	var t = get_tree().create_tween().set_trans(Tween.TRANS_QUAD)
	t.tween_property(shaders[0].material,"shader_parameter/shake_color_rate",0,time)
	var t2 = get_tree().create_tween().set_trans(Tween.TRANS_QUAD)
	t2.tween_property(shaders[0].material,"shader_parameter/shake_power",0,time)
	await t2.finished
	shaders[0].hide()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	scrollice(delta)
	self.rotation_degrees = shakerotation + degrotation
	if shakeamt:
		shakeamt = max(shakeamt-delta*decay,0)
		shake(delta)
func addshake(n:float):
	shakeamt += n
	if shakeamt > max(maxmult*n,maxmult*0.7):
		shakeamt = maxmult*n

func shake(delta):
	var amt = shakeamt/5*power * int(Data.settings["vfxmult"])
	t+=1
	shakerotation = (rotate * amt * (noise.get_noise_2d(noise.seed*0.97*t,t)))
	self.offset.x = max_offset.x * amt * (noise.get_noise_2d(noise.seed*1.63-t,t))
	self.offset.y = max_offset.y * amt * (noise.get_noise_2d(noise.seed*1.23+t,t))

func finalityend():
	shaders[1].show()
	var tw = get_tree().create_tween()
	tw.tween_property(shaders[1].material,"shader_parameter/sort",2,1.4)
	blind(1.4)
	await tw.finished
	unblind(0.5)
	tw = get_tree().create_tween()
	tw.tween_property(shaders[1].material,"shader_parameter/sort",0,0.5)
	await tw.finished
	shaders[1].hide()
	
func scrollice(delta):
	IceOverlay.position.x += IceSpeed*delta
	if IceOverlay.position.x +640>160:
		IceOverlay.position.x-=160
