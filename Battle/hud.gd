extends HBoxContainer
class_name BattleHUD

@onready var Name: RichTextLabel = $Name
@onready var Lv: RichTextLabel = $Lv
@onready var HpBar: ProgressBar = $MarginContainer/HpBar
@onready var KrBar: ProgressBar = $MarginContainer/KrBar
@onready var HpBarContainer: MarginContainer = $MarginContainer
@onready var KrText: RichTextLabel = $KrText/KR
@onready var Hp: RichTextLabel = $Hp


# Called when the node enters the scene tree for the first time.
func _process(_delta: float) -> void:
	Name.text = str(Global.player_name)
	Lv.text = "Lv " + str(Global.player_lv)
	HpBarContainer.custom_minimum_size.x = min(max(Global.player_max_hp*1.2 +1,4), 160)
	HpBar.value = Global.player_hp - Global.player_kr
	KrBar.value = Global.player_hp
	KrBar.max_value = Global.player_max_hp
	HpBar.max_value = Global.player_max_hp
	var hptext := "[color=%s]" % Color.MAGENTA.to_html() if Global.player_kr > 0 else ""
	Hp.text = hptext + "%s / %s" % [Global.player_hp,Global.player_max_hp]


func _ready() -> void:
	_process(0.0)


func set_kr(to := true) -> void:
	KrText.visible = to
	
