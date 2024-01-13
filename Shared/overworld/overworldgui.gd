extends CanvasLayer
class_name OverworldGui

var enabled = false
var canmove = false
var soulpos = 0

var speed = 30.0
var menu1pos = [Vector2(65,201),Vector2(65,243)]
func _ready() -> void:
	$Control/DetailedStats/Rect.modulate.a = 0
	$Control/DetailedStats/Rect2.modulate.a = 0
	$Control.modulate.a = 0
	$Control/Stats/Rect/Name.text = Data.human
	$Control/DetailedStats/Rect/Name.text = "\"%s\"" % Data.human
	$Control/Stats/Rect/Stats.text = "LV %s\nHP %s/%s\nG  0" % [Game.lv,Game.hp,Game.hp]
	$Control/DetailedStats/Rect/Hp.text = "HP %s/%s" % [Game.hp,Game.hp]
	$Control/DetailedStats/Rect/LV.text = "LV %s" % Game.lv
	$Control/DetailedStats/Rect/Combat.text = "AT %s(20)\nDF %s(69)" % [Game.atk,Game.def]
	$Control/DetailedStats/Rect/Equipment.text = "WEAPON: %s\nARMOR: %s" % [Data.weapon,Data.armor]
	var items = ""
	for i in Data.items.size():
		items +=Data.itemNames[Data.items[i]]+"\n"
	$Control/DetailedStats/Rect2/Items.text = items
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("slow_down")&&enabled&&canmove:
		var tw = get_tree().create_tween().set_trans(Tween.TRANS_CIRC)
		tw.tween_property($Control,"modulate:a",0,0.5)
		enabled = false
		canmove = false
		Global.canmove = true
		return
	if event.is_action_pressed("openmenu")&&!enabled:
		var tw = get_tree().create_tween().set_trans(Tween.TRANS_CIRC)
		tw.tween_property($Control,"modulate:a",1,0.5)
		enabled = true
		canmove = true
		Global.canmove = false
		return
	if !enabled:
		return
	if event.is_action_pressed("ui_down")&&soulpos <1&&canmove:
		soulpos += 1
		$Control/squeak.play()
	if event.is_action_pressed("ui_up")&&soulpos>0&&canmove:
		soulpos -= 1
		$Control/squeak.play()
	
	if event.is_action_pressed("Confirm"):
		if soulpos == 0&&canmove:
			$Control/select.play()
			showdetailed($Control/DetailedStats/Rect2)
		if soulpos == 1&&canmove:
			$Control/select.play()
			showdetailed($Control/DetailedStats/Rect)
	if event.is_action_pressed("slow_down"):
		if soulpos == 0&&!canmove:
			hidedetailed($Control/DetailedStats/Rect2)
		if soulpos == 1&&!canmove:
			hidedetailed($Control/DetailedStats/Rect)
func showdetailed(whichone):
	canmove = false
	$Control/DetailedStats.size.y = 0
	var tw = get_tree().create_tween().set_trans(Tween.TRANS_CIRC)
	tw.tween_property($Control/DetailedStats,"size:y",401,0.5)
	var tw2 = get_tree().create_tween().set_trans(Tween.TRANS_CIRC)
	tw2.tween_property(whichone,"modulate:a",1,0.5)
	
func hidedetailed(whichone):
	$Control/DetailedStats.size.y = 401
	var tw = get_tree().create_tween().set_trans(Tween.TRANS_CIRC)
	tw.tween_property($Control/DetailedStats,"size:y",0,0.5)
	var tw2 = get_tree().create_tween().set_trans(Tween.TRANS_CIRC)
	tw2.tween_property(whichone,"modulate:a",0,0.5)
	canmove = true
	await tw2.finished
	

func _process(delta: float) -> void:
	$Control/Soul.position = $Control/Soul.position.lerp(menu1pos[soulpos],delta * speed)
