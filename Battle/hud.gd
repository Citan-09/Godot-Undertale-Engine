extends HBoxContainer
class_name BattleHUD

@onready var Name = $Name
@onready var Lv = $Lv
@onready var HpBar = $MarginContainer/HpBar
@onready var KrBar = $MarginContainer/KrBar
@onready var HpBarContainer = $MarginContainer
@onready var KrText = $KrText/KR
@onready var Hp = $Hp

var kr = false
# Called when the node enters the scene tree for the first time.
func _process(delta: float) -> void:
	Name.text = str(Global.player_name)
	Lv.text = "Lv " + str(Global.player_lv)
	HpBarContainer.custom_minimum_size.x = min(max(Global.player_max_hp*1.2 +1,4),220)
	HpBar.value = Global.player_hp - Global.player_kr
	KrBar.value = Global.player_hp
	KrBar.max_value = Global.player_max_hp
	HpBar.max_value = Global.player_max_hp
	var hptext = "[color=%s]" % Color(KrBar.tint_progress).to_html() if Global.player_kr >0 else ""
	Hp.text = hptext + "%s / %s" % [Global.player_hp,Global.player_max_hp]

func _ready():
	_process(0.0)
func set_kr(to:bool = true):
	if to:
		KrText.show()
	else:
		KrText.hide()
	
