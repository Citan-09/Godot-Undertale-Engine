extends Fightmanager
class_name papyrusencounter

@onready var spike = preload("res://BattleEngine/Fight_Manager/Enemies/Papyrus/bone_spike_fake.tscn")
@onready var bullets = [preload("res://BattleEngine/Fight_Manager/Enemies/Papyrus/skateboard.tscn"),preload("res://BattleEngine/Fight_Manager/Enemies/Papyrus/CoolDude.tscn")]
@onready var gui: guicontrollertp = get_node("/root/main/Camera2D/gui")
var defcol = Color("777dcd")
@export var memorycol = Color("777dcd")
@onready var Modulate:CanvasModulate = get_node("/root/main/vfx/CanvasModulate")
@onready var Memory =  get_node("/root/main/Memory")
@export var bcolor = Color.WHITE
var disabledinput = false

func init():
	Game.tpcd = -100000000000000000
	bonecolor = bcolor
	blastercolor = bcolor
	if !Data.settings["vfxmult"]:
		vfx.hide()
	blastercolor = Color("a3a9b8")
	bonecolor = Color("a3a9b8")
	Box.encounter = "papyrus"
	await get_tree().process_frame
	Butn.enable()

func _process(delta):
	if gui:
		gui.refreshtpbar()
func _input(event: InputEvent) -> void:
	if disabledinput:
		get_viewport().set_input_as_handled()
	

func predeath():
	if vfx:
		vfx.hide()
	if get_node("/root/main/fog"):get_node("/root/main/fog").hide()
	get_node("/root/main/attacks").queue_free()
	allbones.queue_free()
	Boss.mute()

func castbullet(id:int = 0,posx=0,posy=0,velx=0,vely=0):
	var clone = bullets[id].instantiate()
	allbones.add_child(clone)
	clone.position = Vector2(posx,posy)
	clone.fire(velx,vely)

var textp = [
	"4SANS... LISTEN TO ME VERY CAREFULLY."
	,"4YOU MUST BECOME DUSTNUTS..."
	,"4IT IS THE ONLY WAY TO DEFEAT HUMAN SANS!!!!"
	,"4PLEASE I AM DIEEDING"]
var texts = [
	"papyrus! i.. i..'m sorry papyrus!",
	"i.. didn't... m-",
	"... i don't... want to...",
	"it's dustin time!"
]
func finalcutscene():
	Player.intomenu()
	await get_tree().create_timer(0.4,false).timeout
	Box.ast.show()
	Box.blitter.show()
	for i in 2:
		Box.typetext(texts[i])
		await get_tree().create_timer(2,false).timeout
	Boss.typetext([textp[0],textp[1]])
	await get_tree().create_timer(2,false).timeout
	Boss.emit_signal("confirm")
	await get_tree().create_timer(2,false).timeout
	Box.typetext(texts[2])
	await get_tree().create_timer(2,false).timeout
	Boss.typetext([textp[2],textp[3]])
	await get_tree().create_timer(2,false).timeout
	Boss.emit_signal("confirm")
	await get_tree().create_timer(2,false).timeout
	Box.typetext(texts[3])
	await Boss.musE.finished
	Camera.blind(0.8)
	await Camera.faded
	Data.unlockedfights["papyrus"] = true
	Data._savegame()
	get_tree().change_scene_to_file("res://Menu/menu.tscn")
