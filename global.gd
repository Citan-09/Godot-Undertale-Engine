extends CanvasLayer

var fullscreen = false
var debugmode = false

var boxesinmenu := false
var unlockedboxes = 0
var equipment:Dictionary = {"weapon":3,"armor":2}
var cells:Array #[]
var items:Array #[null,null,null,null,null,null,null,null]
var boxitems:Array #[[],[],[]]
var settings:Dictionary = {"music":100,"sfx":100,"misc":100,"vfx":false}

var savepath = "user://savegame.bin"

signal saved

enum types{
	CONSUMABLE,
	WEAPON,
	ARMOR
}

# overworld
var player_in_menu = false
var player_can_move = true
var paused = false


# stats
var player_name = "ERROR"
var player_gold = 0
var player_lv = 1
var player_exp = 0
var player_hp = 20
var player_max_hp = 20
var player_defense = 0
var player_attack = 10
var player_kr = 0

var krtime = 0.5

# Temps.
var temp_atk : int = 0
var temp_def : int = 0
var player_position := Vector2.ZERO
var encounter_resource : Encounter
var overworld_temp_data = {
	"global_position" : Vector2.ZERO,
}
# Overworld
var overworld_data := {
	"room" : null
}
var flags := {
	"done_sans" : false
}

var playtime = 0.0
var cache_playtime = 0.0
#region items
var ItemStats = {
	"weaponspeed": 1.0,
	"weaponbars": 1,
	"bartranstype": Tween.TRANS_CUBIC,
	"weapontype": weaponstype.KNIFE,
	"itemtype": types.CONSUMABLE,
	"name": "TestItem",
	"use_message": ["item used!"],
	"information": ["* Test Item - Heals 0 hp \n* This means this item has no description or is the default item."],
	"heal": 0,
	"attack": 0,
	"defense": 0
}

enum weaponstype{
	KNIFE,
	PUNCH,
	SHOE,
	BOOK,
	PAN,
	GUN
}

## USE THESE TO ADD NEW ITEMS
@export var item_list :Array[Item] = [
]

var item_set_1=[
	0,
	1,
	1,
	0,
	1,
	1,
	0,
	0
]

@onready var heal_sound = $heal

func item_use_text(inv_pos:int):
	if inv_pos > 7: inv_pos = 7
	if inv_pos <0: inv_pos = 0
	var item = item_list[items[inv_pos]]
	var use_text = item.use_message
	if item.heal_amount:
		heal(item["heal"])
		use_text.append("* You healed  %s HP" % [item.heal_amount])
	if item.defense_amount:
		if item["itemtype"] == types.CONSUMABLE:
			temp_def += item.defense_amount
			use_text.append("* Gain %s DEF for this battle" % [item.defense_amount])
		else:
					player_defense += item.defense_amount
					use_text.append("* +%s DEF!" % [item.defense_amount])
	if item.attack_amount:
		if item["itemtype"] == types.CONSUMABLE:
			temp_def += item["attack"]
			use_text.append("* Gain %s DEF for this battle" % [item.attack_amount])
		else:
			player_defense += item.attack_amount
			use_text.append("* +%s ATK!" % [item.attack_amount])
	return use_text

func set_item(position:int,id:int):
	if items.size()-1 < position:
		items.resize(position+1)
	if item_list.size() >= id:
		items[position] = id
#endregion

func heal(amt:int):
	heal_sound.play()
	##check max hp
	if player_hp + amt > player_max_hp: amt = player_max_hp - player_hp
	player_hp += amt
	return amt

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_fullscreen"):
		if !fullscreen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		fullscreen = !fullscreen
	if event.is_action_pressed("debug") and OS.is_debug_build():
		toggle_collision_shape_visibility()
		debugmode = not debugmode
	if event.is_action_pressed("force_save"):
		savegame()
		MusicController.play_music_key("other","save",false)

func _unhandled_input(event: InputEvent) -> void:
	if debugmode:
		if event.is_action_pressed("refresh_scene"):
			player_hp = player_max_hp
			player_can_move = true
			player_in_menu = false
			get_tree().reload_current_scene.call_deferred()

func _ready() -> void:
	loadgame()
	for i in item_set_1.size():
		set_item(i,item_set_1[i])
	

func _process(delta: float) -> void:
	playtime += delta
	if debugmode:
		$Info.text = "[rainbow]Debug Enabled[/rainbow] \nFPS: %s\n[R] Reload current scene" % [Engine.get_frames_per_second()]
	else:
		$Info.text = ""
	
	##KR THING:
	$KrTimer.wait_time = krtime/3.0 if player_kr > 30 else krtime
	

func _notification(what):
	pass
	#if what == NOTIFICATION_WM_CLOSE_REQUEST:
		#savegame()
		#await get_tree().process_frame
		#get_tree().quit()

func savegame():
	var file = FileAccess.open(savepath,FileAccess.WRITE)
	var savedata = {
		"stats":
			{
				"gold":player_gold,
				"exp":player_exp,
				"name":player_name,
				"lv":player_lv,
				"hp":player_hp,
				"max_hp":player_max_hp,
				"def":player_defense,
				"atk":player_attack
			}
		,"inv":
			{
				"equipment":equipment,
				"items": items,
				"cells": cells,
				"unlockedboxes": unlockedboxes,
				"boxinv": boxitems,
				"boxinmenu": boxesinmenu,
			}
		,"settings": settings
		,"overworld": overworld_data
		,"flags": flags
		,"playtime": playtime
	}
	cache_playtime = playtime
	file.store_line(JSON.stringify(savedata))
	
	
func loadgame():
	var file = FileAccess.open(savepath,FileAccess.READ)
	if FileAccess.file_exists(savepath) and !file.eof_reached():
		var savedata= JSON.parse_string(file.get_as_text())
		if savedata == null:
			savedata = {}
		# EQUIPMENT
		equipment.merge(savedata.get("inv",{}).get("equipment"),true)
		# ITEMS
		items= savedata.get("inv",{}).get("items",[null,null,null,null,null,null,null,null])
		# DIM BOXES
		boxesinmenu = savedata.get("inv",{}).get("boxinmenu",false)
		boxitems = savedata.get("inv",{}).get("boxinv",[[],[],[]])
		unlockedboxes = savedata.get("inv",{}).get("unlockedboxes",0)
		# CELLS
		cells = savedata.get("inv",{}).get("cells",[])
		# SETTINGS
		settings.merge(savedata.get("settings",settings),true)
		# PLAYER STATS
		player_name = savedata.get("stats",{}).get("name",player_name)
		player_attack = savedata.get("stats",{}).get("atk",player_attack)
		player_defense = savedata.get("stats",{}).get("def",player_defense)
		player_hp = savedata.get("stats",{}).get("hp",player_hp)
		player_max_hp = savedata.get("stats",{}).get("max_hp",player_max_hp)
		player_lv = savedata.get("stats",{}).get("lv",player_lv)
		player_exp = savedata.get("stats",{}).get("exp",player_exp)
		player_gold = savedata.get("stats",{}).get("gold",player_gold)
		playtime = savedata.get("playtime",0.0)
		cache_playtime = playtime
		# OVERWORLD
		overworld_data.merge(savedata.get("overworld",{}),true)
		# FLAGS
		flags.merge(savedata.get("flags",{}),true)
	refresh_audio_busses()
	
func refresh_audio_busses():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"),linear_to_db(settings["sfx"]/100.0))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Misc"),linear_to_db(settings["misc"]/100.0))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),linear_to_db(settings["music"]/100.0))
	
func toggle_collision_shape_visibility() -> void:
	var tree := get_tree()
	tree.debug_collisions_hint = ! tree.debug_collisions_hint
	var node_stack: Array[Node] = [tree.get_root()]
	while not node_stack.is_empty():
		var node: Node = node_stack.pop_back()
		if is_instance_valid(node):
			if node is TileMap:
				node.collision_visibility_mode = TileMap.VISIBILITY_MODE_FORCE_HIDE
				node.collision_visibility_mode = TileMap.VISIBILITY_MODE_DEFAULT
			if node is CollisionShape2D or node is CollisionPolygon2D or node is  RayCast2D:
				node.queue_redraw()
			node_stack.append_array(node.get_children())
			
	
func _on_kr_tick() -> void:
	if player_kr > 0:
		player_kr -= 1
		player_hp -= 1

func check_level_up():
	var lv = player_lv
	var lvup
	if player_exp >= 10:
		lv = 2
	if player_exp >= 30:
		lv = 3
	if player_exp >= 70:
		lv = 4
	if player_exp >= 120:
		lv = 5
	if player_exp >= 200:
		lv = 6
	if player_exp >= 300:
		lv = 7
	if player_exp >= 500:
		lv = 8
	if player_exp >= 800:
		lv = 9
	if player_exp >= 1200:
		lv = 10
	if player_exp >= 1700:
		lv = 11
	if player_exp >= 2500:
		lv = 12
	if player_exp >= 3500:
		lv = 13
	if player_exp >= 5000:
		lv = 14
	if player_exp >= 7000:
		lv = 15
	if player_exp >= 10000:
		lv = 16
	if player_exp >= 15000:
		lv = 17
	if player_exp >= 25000:
		lv = 18
	if player_exp >= 50000:
		lv = 19
	if player_exp >= 99999:
		lv = 20
	if lv != player_lv:
		lvup = 1
		player_max_hp = 16 + lv * 4
		player_attack = 8 + lv * 2
		player_defense = 9 + ceil(lv / 4.0)
		if lv == 20:
			player_max_hp = 99
			player_attack = 99
			player_defense = 99
	else:
		lvup = 0
	
	player_lv += lvup
	
	return lvup

func load_battle(battle_scene_path:String = "res://Battle/battle.tscn",battle_resource :Encounter = preload("res://Resources/Encounters/EncounterTest.tres"),transistion := true,to_position := Vector2(48,452)):
	if transistion:
		var screen = load("res://Overworld/battle_transistion.tscn").instantiate()
		screen.target = to_position
		get_tree().current_scene.add_child(screen)
		await screen.transistion()
	player_in_menu = false
	player_can_move = true
	encounter_resource = battle_resource
	get_tree().change_scene_to_file(battle_scene_path)
	
	
	
func exit_battle():
	pass
