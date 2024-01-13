extends CanvasLayer
class_name FightTransistioner
@onready var Soul = $Soul
@onready var Flash = $ColorRect
const Fightpos = Vector2(50,453)
@export var encounters = {"sans":"res://BattleEngine/Fight_Manager/SansDrip/sansfight.tscn"}
func _ready():
	Soul.hide()
	Flash.hide()
	
##DEFAULTS:
#var lv = 8
#var hp = 48
#var atk = 70
#var def = 16

func PreFightChanges(fight):
	match fight:
		"papyrus":
			Data.human = "sans"
			Game.lv = 1
			Game.def = 0
			Game.atk = 22
			Game.hp = 1
			Game.krbool = false
			Data.changeitemset("set2")
		
		"sans":
			Game.lv = 8
			Game.hp = 48
			Game.atk = 70
			Game.def = 16
			Data.human = "chara"
			Data.changeitemset("set1")
			
func directbattle(fight):
	PreFightChanges(fight)
	Game.setmonster(fight)
	get_tree().change_scene_to_file(encounters[fight])
func intobattle(startpos:Vector2 = Vector2.ZERO,fight = "sans",soultype = "human"):
	PreFightChanges(fight)
	print(startpos)
	if soultype != "human":
		Soul.modulate = Color.WHITE
		Soul.frame = 3
	else:
		Soul.modulate = Color.RED
		Soul.frame = 0
	Game.setmonster(fight)
	Soul.show()
	for i in 3:
		$Noise.play()
		Flash.show()
		await get_tree().create_timer(0.05).timeout
		if Data.settings["vfxmult"]:
			Flash.hide()
		await get_tree().create_timer(0.05).timeout
	var t = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	t.tween_property(Soul,"position",Fightpos,0.4)
	t.tween_property(Soul,"modulate:a",0,0.3)
	Flash.show()
	$Drop.play()
	await t.finished
	get_tree().change_scene_to_file(encounters[fight])
