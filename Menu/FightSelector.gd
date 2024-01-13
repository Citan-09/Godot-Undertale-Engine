extends Control
@onready var List = $ListOfFights
@onready var battle:FightTransistioner = get_node("/root/menu/IntoFight")

@onready var icons = [load("res://Shared/Text/cross.png"),load("res://Shared/Text/checkmark.png")]

var unlockedfights = {}
var currentboss = ""
var count = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	checkunlocked()

func checkunlocked():
	unlockedfights.merge(Data.unlockedfights,true)
	for i in List.item_count:
		currentboss = fights[count]
		List.set_item_disabled(count,!unlockedfights.get(currentboss))
		List.set_item_icon(count,icons[int(unlockedfights.get(currentboss))])
		count += 1
	count = 0

#var diffsoul:Dictionary = {
#	"papyrus": "monster"
#}
#,diffsoul.get(fights[index],"human") <---
	
var fights = [
	"sans"
	,"papyrus"
]

func _on_list_of_fights_item_activated(index):
	battle.directbattle(fights[index])

