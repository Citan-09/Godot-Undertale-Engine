extends Node

var human = "CHARA"

#SETTINGS
var savepath = "user://savegame.bin"
var savegamefull:Dictionary
var settings = {
	"volume" : 100
	,"vfxmult" : false
}
var unlockedfights = {
	"sans":false
	,"papyrus":false
}

var itemsets = {}
const HealAmounts = [999,60,40,60,45,1] # By ID
var default
var items:Array
var itemNames = ["Pie","Thin Ice","Burgor","F. Steak","Snow Piece","Ketchup"]

var weapon = "Real Knife"
var armor = "Amongus Hat"

var currentpage = 1
signal saved 
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		quitsave()
		
func createsavejson():
	savegamefull.merge({"settings":settings,"unlockedfights":unlockedfights},true)
func quitsave():
	createsavejson()
	var file = FileAccess.open(savepath,FileAccess.WRITE)
	var data = JSON.stringify(savegamefull)
	file.store_line(data)
	file.flush()
	get_tree().quit()
func _loadgame():
	var file = FileAccess.open(savepath,FileAccess.READ)
	if FileAccess.file_exists(savepath) && !file.eof_reached():
		var data:Dictionary = JSON.parse_string(file.get_as_text())
		if !data.get("settings"):
			data.merge({"settings":settings},true)
		if !data.get("unlockedfights"):
			data.merge({"unlockedfights":unlockedfights},true)
		settings = data["settings"]
		unlockedfights = data["unlockedfights"]
		
func _savegame():
	createsavejson()
	var file = FileAccess.open(savepath,FileAccess.WRITE)
	var data = JSON.stringify(savegamefull)
	file.store_line(data)
	emit_signal("saved")
	
func _ready():
	_loadgame()
	init()
func init():
	changeitemset("set1")

func changeitemset(setname = "set1"):
	items.clear()
	itemsets= JSON.parse_string(FileAccess.open("res://Shared/Text/ItemsList.json",FileAccess.READ).get_as_text())
	items = itemsets[setname]

func _process(delta):
	if Input.is_action_just_pressed("ui_leave"):
		init()

func returnItemArray(pos):
	var list: String
	if pos >4:
		for i in min(items.size()-4,4):
			list += itemNames[items[i+4]]
			list += "\n"
			if currentpage != 2:
				currentpage = 2
	elif pos <5:
		for i in min(items.size(),4):
			list += itemNames[items[i]]
			list += "\n"
			if currentpage != 1:
				currentpage = 1
	return list
func UseItem(pos):
	var Main = get_node("/root/main")
	var heal = HealAmounts[items.pop_at(pos)]
	return heal
