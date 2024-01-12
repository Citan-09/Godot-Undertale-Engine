extends CanvasLayer

const sizethingys = {PADDING = 40 , SIZE_PER_OPTION = 40}
@export var ItemsSeperation := Vector2.ZERO
@export var OptionSeperation := Vector2.ZERO

@onready var Soul : Sprite2D = $Control/StatAndOptions/Soul
@onready var Stats = $Control/StatAndOptions/Detailed
@onready var Items = $Control/StatAndOptions/Items
@onready var Cells = $Control/StatAndOptions/Cells
@onready var Item_Actions = {
	0.0 : $Control/StatAndOptions/Items/Use,
	1.0 : $Control/StatAndOptions/Items/Info,
	2.0 : $Control/StatAndOptions/Items/Drop
}
var soulposition := Vector2.ZERO
var optionsize = {
	states.OPTIONS : Vector2(1,3),
	states.STATS : Vector2.ZERO,
	states.ITEM : Vector2(1,1),
	states.ITEM_ACTION : Vector2(3,1),
	states.CELL : Vector2.ONE,
}
var textboxscene = preload("res://Overworld/text_box.tscn")
var textbox : TextBox
@onready var soultarget : Vector2 = $Control/StatAndOptions/Options/Options.global_position
var current_state = states.OPTIONS

enum states{
	OPTIONS,
	STATS,
	ITEM,
	ITEM_ACTION,
	CELL,
}
var enabled_options = [
	true,
	true,
	false,
]
@export var options_dict :={
	0 : "ITEM",
	1 : "STATS",
	2 : "CELL",
	3 : "BOX",
}
var pos_history = {
	states.OPTIONS : null,
	states.STATS : null,
	states.ITEM : null,
	states.ITEM_ACTION : null,
	states.CELL : null,
}
# Called when the node enters the scene tree for the first time.
func _ready():
	Global.player_in_menu = true
	_set_overview()
	_write_options()
	_set_enabled_options()
	$Control/StatAndOptions/Options.grow()
	$Control/StatAndOptions/Stats.grow()

func _in_state(state : states):
	pos_history[current_state] = soulposition
	if pos_history[state] != null:
		soulposition = pos_history[state]
	else:
		soulposition = Vector2.ZERO
	current_state = state
	match state:
		states.OPTIONS:
			Items.shrink()
			Stats.shrink()
			Cells.shrink()
		states.ITEM:
			_set_items()
			Items.grow()
		states.STATS:
			_set_detailed()
			Stats.grow()
		states.CELL:
			_set_cells()
			Cells.grow()
	soul_move(Vector2.ZERO)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# sets which options are enabled (they show as white instead of gray)
func _set_enabled_options():
	var enabled_array = []
	for i in enabled_options.size():
		# CHECK CONDITIONS
		match i:
			0:
				enabled_array.append(Global.items.size() > 0)
			1:
				enabled_array.append(true)
			2:
				enabled_array.append(Global.cells.size() > 0)
			3:
				if Global.boxesinmenu:
					enabled_array.append(Global.unlockedboxes.size() > 0)
	enabled_options = enabled_array
	
func _write_options():
	_set_enabled_options()
	var txt = ""
	for i in enabled_options.size():
		txt += "[color=%s]%s[/color]\n" % ["white" if enabled_options[i] else "gray",options_dict[i]]
	$Control/StatAndOptions/Options/Options.text = txt

func _set_overview():
	$Control/StatAndOptions/Stats/Name.text = Global.player_name
	$Control/StatAndOptions/Stats/Stats.text = "LV %s\nHP %s/%s\nG   %s" % [Global.player_lv,Global.player_hp,Global.player_max_hp,Global.player_gold]

func _set_detailed():
	$Control/StatAndOptions/Detailed/Name.text = "%s" % Global.player_name
	$Control/StatAndOptions/Detailed/Hp.text = "HP %s/%s" % [Global.player_hp,Global.player_max_hp]
	$Control/StatAndOptions/Detailed/Stats.text = "AT %s(%s) \nDF %s(%s)" % [
		Global.player_attack,
		Global.item_list[Global.equipment["weapon"]].attack_amount + Global.item_list[Global.equipment["armor"]].attack_amount,
		Global.player_defense,
		Global.item_list[Global.equipment["weapon"]].defense_amount + Global.item_list[Global.equipment["armor"]].defense_amount
		]
	$Control/StatAndOptions/Detailed/Equipment.text = "WEAPON: %s \nArmor: %s" % [Global.item_list[Global.equipment["weapon"]].item_name, Global.item_list[Global.equipment["armor"]].item_name]
	$Control/StatAndOptions/Detailed/Gold.text = "GOLD: %s" % Global.player_gold
	$Control/StatAndOptions/Detailed/Lv.text = "LV %s" % Global.player_lv
	$Control/StatAndOptions/Detailed/Exp.text = "EXP %s" % Global.player_exp

func _set_items():
	var txt := ""
	for i in Global.items.size():
		txt += "%s\n" % Global.item_list[Global.items[i]].item_name
	optionsize[states.ITEM] = Vector2(1,Global.items.size())
	$Control/StatAndOptions/Items/Items.text = txt

func _set_cells():
	pass # OVERWRITE THIS IF U WANT

func _close_menu():
	Items.shrink()
	Stats.shrink()
	Cells.shrink()
	Global.player_in_menu = false
	set_process_unhandled_input(false)
	$Control/StatAndOptions/Stats.shrink()
	$Control/StatAndOptions/Options.shrink()
	var tw = create_tween()
	tw.tween_property($Control/StatAndOptions/Soul,"modulate:a",0,0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	await $Control/StatAndOptions/Options.tw.finished
	queue_free()

func _unhandled_input(event):
	if event.is_action_pressed("ui_down"):
		soul_move(Vector2.DOWN)
	if event.is_action_pressed("ui_up"):
		soul_move(Vector2.UP)
	if event.is_action_pressed("ui_right"):
		soul_move(Vector2.RIGHT)
	if event.is_action_pressed("ui_left"):
		soul_move(Vector2.LEFT)
	if event.is_action_pressed("ui_accept"):
		$Control/StatAndOptions/Soul/Ghost.restart()
		$Control/StatAndOptions/Soul/Ghost.emitting = true
		$select.play()
		match current_state:
			states.OPTIONS:
				if enabled_options[soulposition.y]:
					match soulposition.y:
						0.0:
							_in_state(states.ITEM)
						1.0:
							_in_state(states.STATS)
						2.0:
							_in_state(states.CELL)
			states.ITEM:
				_in_state(states.ITEM_ACTION)
			states.CELL:
				_in_state(states.CELL)
			states.ITEM_ACTION:
				match soulposition.x:
					0.0:
						_close_menu()
						textbox = textboxscene.instantiate()
						get_tree().current_scene.add_child(textbox)
						textbox.generic(Global.item_use_text(soulposition.y))
						Global.items.remove_at(soulposition.y)
						_set_items()
					1.0:
						_close_menu()
						textbox = textboxscene.instantiate()
						get_tree().current_scene.add_child(textbox)
						textbox.generic(Global.item_list[Global.items[soulposition.y]].item_information)
					2.0:
						_close_menu()
						textbox = textboxscene.instantiate()
						get_tree().current_scene.add_child(textbox)
						textbox.generic(Global.item_list[Global.items[soulposition.y]].throw_message)
						Global.items.remove_at(soulposition.y)
						_set_items()
	if event.is_action_pressed("ui_cancel"):
		match current_state:
			states.ITEM:
				_in_state(states.OPTIONS)
			states.CELL:
				_in_state(states.OPTIONS)
			states.ITEM_ACTION:
				_in_state(states.ITEM)
			states.STATS:
				_in_state(states.OPTIONS)
			states.OPTIONS:
				_close_menu()

func soul_move(action: Vector2):
	$choice.play()
	if soulposition.x + action.x > optionsize[current_state].x - 1:  return false
	if soulposition.y + action.y > optionsize[current_state].y - 1:  return false
	
	if soulposition.x + action.x < 0:  return false
	if soulposition.y + action.y < 0:  return false
	soulposition += action
	match current_state:
		states.OPTIONS:
			soultarget = $Control/StatAndOptions/Options/Options.global_position + soulposition * OptionSeperation
		states.ITEM:
			soultarget = $Control/StatAndOptions/Items/Items.global_position + soulposition * ItemsSeperation
		states.ITEM_ACTION:
			soultarget = Item_Actions[soulposition.x].global_position
		states.CELL:
			soultarget = $Control/StatAndOptions/Cells/Numbers.global_position + soulposition * ItemsSeperation
	Soul.global_position = soultarget + Vector2(-12,15)
	$Control/StatAndOptions/Soul/Ghost.restart()
	$Control/StatAndOptions/Soul/Ghost.emitting = true
