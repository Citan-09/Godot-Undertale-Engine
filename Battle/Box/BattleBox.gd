@icon("res://Battle/Box/battleboxicon.png")
extends Node
class_name BattleBox

@export var Duration = 0.7
@export var TransType = Tween.TRANS_QUAD
@export var EaseType = Tween.EASE_OUT

@export_range(0, 1) var flee_chance: float = 0.2
@export var mercytexts = ["* You spared the enemies.", "* You fled.", "* Failed to flee."]
@export var wintext = "* You won! \n* You Earned %s EXP and %s Gold."
@onready var Blitter = $Blitter
@onready var Blittertext: GenericTextTyper = $Blitter/Text
var anchor_targets = [Vector2(220, 140), Vector2(420, 340)]
#TL, TR, BL, BR

var tw: Tween
var cornerpositions
@onready var main: BattleMain = $/root/main
@onready var container: MarginContainer = $BoxContainer
var options_pos_base = Vector2(76, 286)
var options_pos_step = Vector2(257, 30)
@onready var collisions = [$BoxContainer/Collisions/Top, $BoxContainer/Collisions/Bottom, $BoxContainer/Collisions/Left, $BoxContainer/Collisions/Right]
var colsize = 6
@onready var Texts = [$Blitter, $Target, $Acts, $Items, $Mercy]
enum {
	RELATIVE_TOP_LEFT,
	RELATIVE_TOP_RIGHT,
	RELATIVE_BOTTOM_LEFT,
	RELATIVE_BOTTOM_RIGHT,
	RELATIVE_CENTER
}

signal movetobuttons
signal movesoul(newpos: Vector2)
signal exitmenu
signal act(target, option: int)
signal fight(target)
signal item(item_choice: int)
signal mercy(target)

var mercychoice = 0
var currenttarget = 0
var button_choice = 0
var soulposition := Vector2i(0, 0)
var choicesextends := [1, 1, 1, 1, 1, 1]
var history = [[null, null], [null, null], [null, null], [null, null]]
var ActionMemory = [state.Disabled]

const itemsize = 1
##STATS
var enemies: Array[Node] = []

func setenemies(Enemies: Array):
	enemies = Enemies
	settargets()

func settargets():
	var Targets = ""
	for i in enemies.size():
		if main.enemies[i]:
			Targets += "  * [color=%s]%s[/color]\n" % ["yellow" if enemies[i].enemy_states[enemies[i].current_state].Sparable else "white", enemies[i].enemy_name]
		else:
			Targets += "    [color=white][/color]\n"
	$Target/Targets.text = Targets

func _debug_finish():
	pass

func set_mercy_options():
	var txt = ""
	var spare_color = "white"
	for i in enemies.size():
		if enemies[i].enemy_states[enemies[i].current_state].Sparable:
			spare_color = "yellow"
	for i in main.encounter.mercy_options.size():
		txt += "[color=%s]%s[/color]\n" % [spare_color, main.encounter.mercy_options[i]]
		spare_color = "white"
	$Mercy/Choices.text = txt
	choicesextends.resize(main.encounter.mercy_options.size())
	choicesextends.fill(1)

enum state {
	Disabled = 0,
	Blittering = 1,
	TargetEnemy = 2,
	Acting = 3,
	Iteming = 4,
	Mercying = 5,
}

func soulpostoid(soulpos: Vector2, x_limit = 2) -> int:
	return soulpos.y * x_limit + soulpos.x

func idtosoulpos(id: int, x_limit: int = 2) -> Array:
	var x = []
	while id > 0:
		if id - x_limit > 0:
			id -= x_limit
			x.append(x_limit)
		else:
			x.append(id)
			id = 0
	return x

func _ready() -> void:
	_physics_process(0.0)
	Blitter.show()
	Blittertext.text = ""
	anchor_targets[0] = Vector2(container.get("theme_override_constants/margin_left"), container.get("theme_override_constants/margin_top"))
	anchor_targets[1] = Vector2(640, 480) - Vector2(container.get("theme_override_constants/margin_right"), container.get("theme_override_constants/margin_bottom"))
	defanchors = anchor_targets.duplicate()

var defanchors = []
func reset_box():
	if tw and tw.is_valid():
		tw.kill()
	anchor_targets = defanchors.duplicate()
	TweenSize(Duration)


func _physics_process(delta: float) -> void:
	var current_size = Vector2(640, 480) - Vector2(container.get("theme_override_constants/margin_right"), container.get("theme_override_constants/margin_bottom")) - Vector2(container.get("theme_override_constants/margin_left"), container.get("theme_override_constants/margin_top"))
	cornerpositions = [Vector2(container.get("theme_override_constants/margin_left"), container.get("theme_override_constants/margin_top")), Vector2(640 -container.get("theme_override_constants/margin_right"), 480 -container.get("theme_override_constants/margin_bottom"))]
	collisions[0].shape.size.x = current_size.x
	collisions[2].shape.size.x = current_size.y
	collisions[0].shape.size.y = colsize
	collisions[2].shape.size.y = colsize

	collisions[0].position = Vector2(cornerpositions[0].x + current_size.x / 2.0, cornerpositions[0].y - (colsize / 2.0 - 5.5))
	collisions[1].position = Vector2(cornerpositions[0].x + current_size.x / 2.0, cornerpositions[1].y + (colsize / 2.0 - 5.5))
	collisions[2].position = Vector2(cornerpositions[0].x - (colsize / 2.0 - 5.5), cornerpositions[0].y + current_size.y / 2.0)
	collisions[3].position = Vector2(cornerpositions[1].x + (colsize / 2.0 - 5.5), cornerpositions[0].y + current_size.y / 2.0)

func returnitempage(pagenumber: int):
	var items: Array
	for i in 4:
		items.append(Global.items[i + pagenumber * 4.0])
	return items

func setoptions():
	var actsd = enemies[currenttarget].enemy_states[0]
	var acts = []
	for i in actsd.Acts.size():
		acts.append(actsd.Acts[i].Act)
	choicesextends = idtosoulpos(acts.size())
	for i in acts.size():
		acts[i] = acts[i].capitalize()
	var actsp1 = ""
	var actsp2 = ""
	for i in acts.size():
		if i == 0:
			actsp1 = "[ul bullet=*]"
		if i == 1:
			actsp2 = "[ul bullet=*]"
		if i % 2 == 0:
			actsp1 += acts[i] + "\n"
		else:
			actsp2 += acts[i] + "\n"

	$Acts/Options/Column1.text = actsp1
	$Acts/Options/Column2.text = actsp2

func setitems():
	var items: PackedStringArray = []
	for i in Global.items.size():
		items.append(Global.item_list[Global.items[i]].item_name + "\n")
	items = items.slice(soulposition.y, soulposition.y + 3)
	$Items/ScrollContainer/Slider.value = soulposition.y
	choicesextends.resize(Global.items.size())
	choicesextends.fill(1)
	$Items/TextContainer/Items.text = "[ul bullet=*]" + "".join(items)

#region OptionsSelecting
func _on_use_button(choice: int):
	button_choice = choice
	match choice:
		0:
			ActionMemory.append(state.TargetEnemy)
		1:
			ActionMemory.append(state.TargetEnemy)
		2:
			if Global.items:
				ActionMemory.append(state.Iteming)
			else:
				emit_signal("movetobuttons")
				return
		3:
			ActionMemory.append(state.Mercying)
			set_mercy_options()
	if history[choice][0]:
		soulposition = history[choice][0]
	else:
		history[choice][0] = soulposition
	soul_choice(Vector2i.ZERO)
	refresh_options()


func backout(steps: int):
	ActionMemory.resize(ActionMemory.size()-steps)
	soul_choice(Vector2i.ZERO)


func refresh_options(append_action = null):
	match append_action if append_action != null else ActionMemory.back():
		state.TargetEnemy:
			choicesextends.resize(enemies.size())
			choicesextends.fill(1)
		state.Iteming:
			setitems()
	if append_action != null:
		ActionMemory.append(append_action)
		if history[button_choice][0] and (ActionMemory.back() == state.TargetEnemy or ActionMemory.back() == state.Iteming):
			soulposition = history[button_choice][0]
		elif history[button_choice][1] and ActionMemory.back() != state.Disabled and ActionMemory.back() != state.Blittering:
			soulposition = history[button_choice][1]
		soul_choice(Vector2i.ZERO)
	var willrefresh: bool = soulposition.y >= choicesextends.size() or soulposition.x > choicesextends[clamp(soulposition.y, 0, max(choicesextends.size()-1, 0))]-1
	if willrefresh:
		while soulposition.y > choicesextends.size() - 1:
			soulposition.y -= 1
		while soulposition.x > choicesextends[min(soulposition.y, choicesextends.size()-1)] - 1:
			soulposition.x -= 1
		soul_choice(Vector2i.ZERO)
	for i in Texts:
		i.hide()
	Texts[ActionMemory.back()-1].show()
	if ActionMemory.back() == state.TargetEnemy:
		currenttarget = soulpostoid(soulposition, 1)

func disable():
	for i in Texts:
		i.hide()
	ActionMemory.resize(1)
	ActionMemory[0] = state.Disabled
	if button_choice != 0:
		button_choice = 0

func _unhandled_input(event: InputEvent) -> void:
	if ActionMemory[0] != state.Disabled:
		if event.is_action_pressed("ui_accept"):
			if ActionMemory.size() > 1:
				if ActionMemory.size() == 4:
					match button_choice:
						1:
							if Blittertext.visibletween.is_valid(): await Blittertext.finishedalltexts
							if button_choice != 0: emit_signal("act", currenttarget, soulpostoid(soulposition))
							disable()
					return
				if ActionMemory.size() == 3:
					match button_choice:
						1:
							refresh_options(state.Blittering)
							emit_signal("exitmenu")
							Blittertext.typetext(enemies[currenttarget].get_act_info(soulpostoid(soulposition)).Description)
						2:
							if Blittertext.visibletween.is_valid(): await Blittertext.finishedalltexts
							if button_choice != 0: emit_signal("item", Global.items[soulpostoid(soulposition)])
							disable()
						3:
							if Blittertext.visibletween.is_valid(): await Blittertext.finishedalltexts
							if button_choice != 0: emit_signal("mercy", mercychoice)
							disable()
					return
				if ActionMemory.size() == 2:
					match button_choice:
						0:
							if main.enemies[currenttarget] != null:
								emit_signal("fight", currenttarget)
								emit_signal("exitmenu")
								disable()
						1:
							if main.enemies[currenttarget] != null:
								setoptions()
								refresh_options(state.Acting)
						2:
							refresh_options(state.Blittering)
							emit_signal("exitmenu")
							Blittertext.typetext(Global.item_use_text(soulpostoid(soulposition)))
							Global.items.remove_at(soulpostoid(soulposition))
						3:
							emit_signal("exitmenu")
							mercychoice = soulpostoid(soulposition, 1)
							if mercychoice == 1 and randf() > flee_chance:
								mercychoice = -1
								Blittertext.typetext(mercytexts[mercychoice])
								refresh_options(state.Blittering)
								return
							Blittertext.typetext(mercytexts[mercychoice])
							refresh_options(state.Blittering)
					return
		if event.is_action_pressed("ui_cancel"):
			if ActionMemory.size() == 2:
				history[button_choice][0] = soulposition
				emit_signal("movetobuttons")
				Blittertext.blitter(main.TurnNumber)
				backout(1)
			elif ActionMemory.back() != state.Disabled and ActionMemory.back() != state.Blittering:
				history[button_choice][1] = soulposition
				backout(1)
		if event.is_action_pressed("ui_down") and ActionMemory.size() > 1:
			if soulposition.y < choicesextends.size() - 1:
				soul_choice(Vector2i.DOWN)
		if event.is_action_pressed("ui_left") and ActionMemory.size() > 1:
			if soulposition.x > 0:
				soul_choice(Vector2i.LEFT)
		if event.is_action_pressed("ui_right") and ActionMemory.size() > 1:
			if soulposition.x < choicesextends[soulposition.y] - 1:
				soul_choice(Vector2i.RIGHT)
		if event.is_action_pressed("ui_up") and ActionMemory.size() > 1:
			if soulposition.y > 0:
				soul_choice(Vector2i.UP)
		if ActionMemory.back() != state.Disabled and event.is_pressed():
			refresh_options()

func soul_choice(action: Vector2i):
	if ActionMemory.back() != state.Blittering:
		soulposition += action
		if ActionMemory.back() == state.Iteming:
			emit_signal("movesoul", options_pos_base + options_pos_step * Vector2(soulposition.x, soulposition.y % itemsize))
		else:
			emit_signal("movesoul", options_pos_base + options_pos_step * Vector2(soulposition.x, soulposition.y))
		if action != Vector2i.ZERO: $Sounds/choice.play()
#endregion
#region Manual Size Changers
func change_size(new_size: Vector2, relative = false, custom_time = null):
	var current_size = anchor_targets[1] - anchor_targets[0]
	var current_center = anchor_targets[0] + current_size / 2.0
	if relative: new_size += current_size
	if new_size.x < container.custom_minimum_size.x: new_size.x = container.custom_minimum_size.x
	if new_size.y < container.custom_minimum_size.y: new_size.y = container.custom_minimum_size.y
	anchor_targets[0] = current_center - new_size / 2.0
	anchor_targets[1] = current_center + new_size / 2.0
	await TweenSize(custom_time)
	return true

func change_position(new_position: Vector2, relative = false, custom_time = null):
	var current_size = anchor_targets[1] - anchor_targets[0]
	if relative: new_position += anchor_targets[0]
	anchor_targets[0] = new_position - current_size / 2.0
	anchor_targets[1] = new_position + current_size / 2.0
	await TweenSize(custom_time)
	return true

func change_anchor(relative_to, new_position: Vector2 = Vector2.ZERO, new_size: Vector2 = Vector2(100, 100), position_relative: bool = false, size_relative: bool = false, custom_time = null):
	var current_size = anchor_targets[1] - anchor_targets[0]
	if size_relative: new_size += current_size
	if new_size.x < container.custom_minimum_size.x: new_size.x = container.custom_minimum_size.x
	if new_size.y < container.custom_minimum_size.y: new_size.y = container.custom_minimum_size.y
	match relative_to:
		RELATIVE_TOP_LEFT:
			if position_relative: new_position += anchor_targets[0]
			anchor_targets[0] = new_position
		RELATIVE_TOP_RIGHT:
			if position_relative: new_position += anchor_targets[0] + current_size.x
			anchor_targets[0] = new_position - new_size.x * Vector2.ONE
		RELATIVE_BOTTOM_LEFT:
			if position_relative: new_position += anchor_targets[0] + current_size.y
			anchor_targets[0] = new_position - new_size.y * Vector2.ONE
		RELATIVE_BOTTOM_RIGHT:
			if position_relative: new_position += anchor_targets[1]
			anchor_targets[0] = new_position - new_size
		RELATIVE_CENTER:
			if position_relative: new_position += anchor_targets[0] + current_size / 2.0
			anchor_targets[0] = new_position - new_size / 2.0

	anchor_targets[1] = anchor_targets[0] + new_size
	await TweenSize(custom_time)

func TweenSize(duration):
	if !duration: duration = Duration
	if not tw or not tw.is_valid():
		tw = create_tween().set_parallel().set_ease(EaseType).set_trans(TransType)
	else:
		tw.pause()
		tw.chain()
	tw.tween_property(container, "theme_override_constants/margin_left", anchor_targets[0].x, duration)
	tw.tween_property(container, "theme_override_constants/margin_top", anchor_targets[0].y, duration)
	tw.tween_property(container, "theme_override_constants/margin_right", 640- anchor_targets[1].x, duration)
	tw.tween_property(container, "theme_override_constants/margin_bottom", 480- anchor_targets[1].y, duration)
	tw.play()
	await tw.finished
	tw.kill()
	return true
#endregion

