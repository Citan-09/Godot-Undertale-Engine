extends Control
class_name guicontroller

var hp
var maxhp
var lv: int = 1

@onready var krbar = $Control/TextureProgressBar/Karma
@onready var hpbar = $Control/TextureProgressBar
@onready var hpnum = $Control/HpInfo
@onready var namedisplay = $NAME
@onready var lvtext = $LV
@onready var player = get_node("/root/main/soul")
# Called when the node enters the scene tree for the first time.
func _initextra():
	pass
func _processextra(delta):
	pass
func _ready():
	lv = Game.lv
	player.hp = Game.hp
	hp = player.hp
	maxhp = hp
	hpbar.max_value = maxhp
	hpbar.value = hp
	hpbar.size.x = max(hp*1.5 +1,3)
	namedisplay.text = Data.human
	lvtext.text = "LV "+str(lv)
	hpnum.text = str(hp) + " / " + str(maxhp)
	hpnum.position.x += hpbar.size.x -10
	krbar.size.x = hp*1.5 +1
	if Game.krbool:
		hpnum.position.x += $Control/KR.size.x
		$Control/KR.position.x += hpbar.size.x -20
	else:
		$Control/KR.hide()
	_initextra()

func refresh():
	hpbar.value = player.hp
	if Game.krbool && player.hp >0:
		krbar.position.x = (hpbar.size.x) *(player.hp-player.kr+1)/maxhp
		krbar.max_value = maxhp
		krbar.value = player.kr
	hpnum.text =(str(player.hp) + " / " + str(maxhp))
	if player.kr !=0 && Game.krbool:
		hpnum.modulate = Color(1,0.32,1,1)
	else:
		hpnum.modulate = Color.WHITE

func _process(delta):
	if Global.debug:
		$Debuginfo.text = "[rainbow freq=3][shake rate=10 level=10][wave amp=40 freq=5]GOD MODE ENABLED"
	else:
		$Debuginfo.text = ""
