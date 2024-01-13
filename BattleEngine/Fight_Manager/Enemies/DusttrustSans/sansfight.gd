extends Fightmanager
class_name sansfight

@export var bcolor = Color("b8a3b8")
@onready var lights = get_node("/root/main/Lights")
var lightarray = []

@onready var video = get_node("/root/main/Video")
##This replaces _ready():
func init():
	blastercolor = bcolor
	bonecolor = bcolor
	lightarray.append_array(lights.get_children())
	#Butn.position.y = 503
	#Butn.modulate.a = 0
	Camera.position_smoothing_enabled = false
	Data.human = "Chara"
	Fight.kb = true
	#var t = get_tree().create_tween()
	#t.tween_property(Butn,"position:y",453,0.4).set_trans(Tween.TRANS_CUBIC)
	#var t2 = get_tree().create_tween()
	#t2.tween_property(Butn,"modulate:a",1,0.4).set_trans(Tween.TRANS_CUBIC)
	#await t2.finished
	

