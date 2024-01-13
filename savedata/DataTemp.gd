extends Node
var startedgame = false

var file = FileAccess.open("res://Shared/Text/EnemyStats.json",FileAccess.READ)
var Mstats = JSON.parse_string(file.get_as_text())

var mname = "null"
var krbool
var hurtframe :float
var mmaxhp
var mhp
var mdef
var matk

var lv = 8
var hp = 48
var atk = 70
var def = 16
var tpcd = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	setmonster()
	pass # Replace with function body.


func setmonster(Name:String = "sans"):
	var Monster= Mstats[Name]
	mname = Name.capitalize()
	mmaxhp = Monster["hp"]
	mhp = mmaxhp
	matk = Monster["atk"]
	mdef = Monster["def"]
	krbool = bool(Monster["kr"])
	hurtframe = Monster["iframe"]


signal tpready
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if tpcd+delta>=3.0&& tpcd<3.0:
		emit_signal("tpready")
	tpcd +=delta
	if tpcd > 3.0:
		tpcd = 3.0
