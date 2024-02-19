@icon("res://Battle/Box/battleboxicon.png")
extends Node2D
class_name BattleBox

@export var Duration: float = 0.7
@export var TransType := Tween.TRANS_QUAD
@export var EaseType := Tween.EASE_OUT

@export_multiline var mercytexts: PackedStringArray = ["* You spared the enemies.", "* You fled.", "* Failed to flee."]
@export var wintext := "* You won! \n* You Earned %s EXP and %s Gold."
var anchor_targets: Array[Vector2] = [Vector2(220, 140), Vector2(420, 340)]
#TL, TR, BL, BR

var tw: Tween
var cornerpositions: Array
var options_pos_base := Vector2(76, 286)
var options_pos_step := Vector2(257, 30)
const colsize: int = 500

var mercychoice: int = 0
var current_target_id: int = 0
var button_choice: int = 0
var soulposition := Vector2i(0, 0)
var choicesextends := [1, 1, 1, 1, 1, 1]
var history: Array = [[null, null], [null, null], [null, null], [null, null]]
var ActionMemory: Array[State] = [State.Disabled]

const itemsize = 1
##STATS
var enemies: Array[Enemy] = []

@onready var HpBarContainer: MarginContainer = $Target/HpBars
@onready var Blitter: MarginContainer = $Blitter
@onready var BlitterText: GenericTextTyper = $Blitter/Text
@onready var Main: BattleMain = $/root/main
@onready var RectContainer: MarginContainer = $BoxContainer
@onready var Rect: NinePatchRect = $BoxContainer/NinePatchRect
var web: PackedScene = preload("res://Battle/Soul/box_web.tscn")
var current_web: int = 0
@onready var Webs: Control = $BoxContainer/NinePatchRect/Webs
@onready var WebsArray: Array[Node] = []
@onready var RectNoClip: Control = $BoxContainer/NinePatchRect/RectNoClip
@onready var RectClip: Control = $BoxContainer/NinePatchRect/Bullets
@onready var Collisions: Array[CollisionShape2D] = [$BoxContainer/Collisions/Top, $BoxContainer/Collisions/Bottom, $BoxContainer/Collisions/Left, $BoxContainer/Collisions/Right]
@onready var HpBars: Array[ProgressBar] = [$"Target/HpBars/Control/1", $"Target/HpBars/Control/2", $"Target/HpBars/Control/3"]

## WARNING: CHANGING THE BOX's SIZE WHILE BULLETS ARE IN THEM MIGHT MOVE THE BULLETS DUE TO HOW SIZE WORKS IN GODOT
enum {
	RELATIVE_TOP_LEFT,
	RELATIVE_TOP_RIGHT,
	RELATIVE_BOTTOM_LEFT,
	RELATIVE_BOTTOM_RIGHT,
	RELATIVE_CENTER
}
enum {
	OPTION_FIGHT = 0,
	OPTION_ACT = 1,
	OPTION_ITEM = 2,
	OPTION_MERCY = 3,
}

signal moved_to_buttons
signal move_soul(newpos: Vector2)
signal exit_menu
signal act(target: int, option: int)
signal fight(target: int)
signal item(item_choice: int)
signal mercy(target: int)

@onready var Screens: Dictionary = {
	State.Blittering: $Blitter,
	State.BlitteringCasual: $Blitter,
	State.TargetEnemy: $Target,
	State.Acting: $Acts,
	State.Iteming: $Items,
	State.Mercying: $Mercy,
}



enum State {
	Disabled,
	BlitteringCasual,
	Blittering,
	TargetEnemy,
	Acting,
	Iteming,
	Mercying,
	Fighting,
}

const BUTTON_ACTIONS = {
	OPTION_FIGHT: State.TargetEnemy,
	OPTION_ACT: State.TargetEnemy,
	OPTION_ITEM: State.Iteming,
	OPTION_MERCY: State.TargetEnemy,
}

func _ready() -> void:
	_physics_process(0.0)
	BlitterText.text = ""
	anchor_targets[0] = Vector2(RectContainer.get("theme_override_constants/margin_left"), RectContainer.get("theme_override_constants/margin_top"))
	anchor_targets[1] = Vector2(640, 480) - Vector2(RectContainer.get("theme_override_constants/margin_right"), RectContainer.get("theme_override_constants/margin_bottom"))
	defanchors = anchor_targets.duplicate()

var defanchors := []
func reset_box() -> void:
	if tw and tw.is_valid():
		tw.kill()
	if !is_zero_approx(RectContainer.rotation):
		RectContainer.rotation = fmod(RectContainer.rotation, PI)
		tw = create_tween().set_ease(EaseType).set_trans(TransType)
		tw.tween_property(RectContainer, "rotation", 0, Duration)
	anchor_targets = defanchors.duplicate()
	TweenSize(Duration)
	clear_webs()

@onready var TL: RemoteTransform2D = $BoxContainer/TL
@onready var BR: RemoteTransform2D = $BoxContainer/BR
var current_size: Vector2

func _physics_process(_delta: float) -> void:
	current_size = Vector2(640, 480) - Vector2(RectContainer.get("theme_override_constants/margin_right"), RectContainer.get("theme_override_constants/margin_bottom")) - Vector2(RectContainer.get("theme_override_constants/margin_left"), RectContainer.get("theme_override_constants/margin_top"))
	cornerpositions = [Vector2(RectContainer.get("theme_override_constants/margin_left"), RectContainer.get("theme_override_constants/margin_top")), Vector2(640 -RectContainer.get("theme_override_constants/margin_right"), 480 -RectContainer.get("theme_override_constants/margin_bottom"))]
	Collisions[0].shape.size.x = current_size.x + colsize
	Collisions[2].shape.size.x = current_size.y + colsize
	Collisions[0].shape.size.y = colsize
	Collisions[2].shape.size.y = colsize

	Collisions[0].position = Vector2(cornerpositions[0].x + current_size.x / 2.0, cornerpositions[0].y - (colsize / 2.0 - 5.5))
	Collisions[1].position = Vector2(cornerpositions[0].x + current_size.x / 2.0, cornerpositions[1].y + (colsize / 2.0 - 5.5))
	Collisions[2].position = Vector2(cornerpositions[0].x - (colsize / 2.0 - 5.5), cornerpositions[0].y + current_size.y / 2.0)
	Collisions[3].position = Vector2(cornerpositions[1].x + (colsize / 2.0 - 5.5), cornerpositions[0].y + current_size.y / 2.0)
	RectContainer.pivot_offset = cornerpositions[0] + current_size / 2.0

	TL.position = cornerpositions[0]
	BR.position = cornerpositions[1]


#region Screens text setting
func setenemies(Enemies: Array) -> void:
	enemies = Enemies
	set_targets()

func set_targets(show_hp_bar := false) -> void:
	var Targets := ""
	for i in enemies.size():
		if Main.enemies[i]:
			Targets += "[color=%s]* %s[/color]\n" % ["yellow" if enemies[i].enemy_states[enemies[i].current_state].Sparable else "white", enemies[i].enemy_name]
		else:
			Targets += "[color=white][/color]\n"
	$Target/Targets.text = Targets
	for i in 3:
		HpBars[i].visible = Main.enemies.size() > i and Main.enemies[i] != null and show_hp_bar
		if !HpBars[i].visible:
			continue
		HpBars[i].max_value = Main.enemies[i].stats.max_hp
		HpBars[i].value = Main.enemies[i].stats.hp


func set_mercy_options() -> void:
	var txt := ""
	var spare_color := "white"
	for i in enemies.size():
		if enemies[i] and enemies[i].enemy_states[enemies[i].current_state].Sparable:
			spare_color = "yellow"
	for i in Main.encounter.mercy_options.size():
		txt += "[color=%s]%s[/color]\n" % [spare_color, Main.encounter.mercy_options[i]]
		spare_color = "white"
	$Mercy/Choices.text = txt
	choicesextends.resize(Main.encounter.mercy_options.size())
	choicesextends.fill(1)


func soulpos_to_id(soulpos: Vector2, x_limit: int = 2) -> int:
	return int(soulpos.y * x_limit + soulpos.x)

func id_to_soulpos(id: int, x_limit: int = 2) -> Array:
	var x := []
	while id > 0:
		if id - x_limit > 0:
			id -= x_limit
			x.append(x_limit)
		else:
			x.append(id)
			id = 0
	return x

func set_options() -> void:
	var acts := []
	for i: int in 6:
		var _act: ActInfo = enemies[current_target_id].get_act_info(i)
		if _act:
			acts.append(_act.Act)
	choicesextends = id_to_soulpos(acts.size())
	var actsp1 := ""
	var actsp2 := ""
	for i in acts.size():
		if i == 0:
			actsp1 = ""
		if i == 1:
			actsp2 = ""
		if i % 2 == 0:
			actsp1 += acts[i] + "\n"
		else:
			actsp2 += acts[i] + "\n"

	$Acts/Options/Column1.text = actsp1
	$Acts/Options/Column2.text = actsp2

func set_items() -> void:
	var items: PackedStringArray = []
	for i: int in Global.items.size():
		items.append(Global.item_list[Global.items[i]].item_name + "\n")
	items = items.slice(soulposition.y, soulposition.y + 3)
	$Items/ScrollContainer/Slider.value = soulposition.y
	choicesextends.resize(Global.items.size())
	choicesextends.fill(1)
	$Items/TextContainer/Items.text = "* " + "* ".join(items)

func _on_use_button(choice: int) -> void:
	soulposition = Vector2.ZERO
	button_choice = choice
	change_state(BUTTON_ACTIONS[choice])
	refresh_options()


func backout() -> void:
	ActionMemory.resize(ActionMemory.size() - 1)
	refresh_nodes()
	soulposition = Vector2.ZERO


@onready var Behaviours: Node = $Behaviours
@onready var current_state_nodes := {
	State.BlitteringCasual: $Behaviours/BlitteringCasual,
	State.Blittering: $Behaviours/Blittering,
	State.TargetEnemy: $Behaviours/Targetting,
	State.Acting: $Behaviours/Acting,
	State.Iteming: $Behaviours/Iteming,
	State.Mercying: $Behaviours/Mercying,
	State.Fighting: $Behaviours/Fighting,
}
@onready var current_state_node: BattleBoxBehaviour = current_state_nodes[State.Blittering]


func change_state(new_state: State) -> void:
	if new_state == ActionMemory.back():
		return
	if new_state == State.Disabled:
			disable()
			return
	ActionMemory.append(new_state)
	refresh_nodes()

func refresh_nodes() -> void:
	refresh_options()
	current_state_node.lose_control()
	current_state_node = current_state_nodes.get(ActionMemory.back(), -2)
	current_state_node.gain_control()



func refresh_options() -> void:
	var willrefresh: bool = soulposition.y >= choicesextends.size() or soulposition.x > choicesextends[clamp(soulposition.y, 0, max(choicesextends.size()-1, 0))]-1
	if willrefresh:
		while soulposition.y > choicesextends.size() - 1:
			soulposition.y -= 1
		while soulposition.x > choicesextends[min(soulposition.y, choicesextends.size()-1)] - 1:
			soulposition.x -= 1


func disable() -> void:
	for i: CanvasItem in Screens.values():
		i.hide()
	ActionMemory.resize(1)
	ActionMemory[0] = State.Disabled
	if button_choice != 0:
		button_choice = 0

var used_item: int = 0

func blitter_flavour() -> void:
	BlitterText.blitter(Main.TurnNumber)
	ActionMemory[0] = State.BlitteringCasual
	Blitter.show()



func blitter_act() -> void:
	await BlitterText.type_text(enemies[current_target_id].get_act_info(soulpos_to_id(soulposition)).Description)


func blitter_item() -> void:
	Global.items.remove_at(soulpos_to_id(soulposition, 1))
	await BlitterText.type_text(Global.item_use_text(used_item))


func blitter_mercy() -> void:
	mercychoice = soulpos_to_id(soulposition, 1)
	randomize()
	var rand := randf()
	if mercychoice == 1 and rand >= Main.encounter.flee_chance:
		mercychoice = -1
		change_state(State.Blittering)
		await BlitterText.type_text([mercytexts[mercychoice]])

		return
	change_state(State.Blittering)
	await BlitterText.type_text([mercytexts[mercychoice]])



func _unhandled_input(event: InputEvent) -> void:
	if ActionMemory[0] != State.Disabled:
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

func soul_choice(action: Vector2i) -> void:
	if ActionMemory.back() != State.Blittering:
		soulposition += action
		if ActionMemory.back() == State.Iteming:
			emit_signal("move_soul", options_pos_base + options_pos_step * Vector2(soulposition.x, soulposition.y % itemsize))
		else:
			emit_signal("move_soul", options_pos_base + options_pos_step * Vector2(soulposition.x, soulposition.y))
		if action != Vector2i.ZERO: $Sounds/choice.play()
#endregion

#region Manual Size Changers
func change_size(new_size: Vector2, relative := false, custom_time: Variant = null) -> void:
	var intended_size := anchor_targets[1] - anchor_targets[0]
	var current_center := anchor_targets[0] + intended_size / 2.0
	if relative: new_size += intended_size
	if new_size.x < RectContainer.custom_minimum_size.x: new_size.x = RectContainer.custom_minimum_size.x
	if new_size.y < RectContainer.custom_minimum_size.y: new_size.y = RectContainer.custom_minimum_size.y
	anchor_targets[0] = current_center - new_size / 2.0
	anchor_targets[1] = current_center + new_size / 2.0
	await TweenSize(custom_time)
	return

func change_position(new_position: Vector2, relative := false, custom_time: Variant = null) -> void:
	var intended_size := anchor_targets[1] - anchor_targets[0]
	if relative: new_position += anchor_targets[0]
	anchor_targets[0] = new_position - intended_size / 2.0
	anchor_targets[1] = new_position + intended_size / 2.0
	await TweenSize(custom_time)
	return

func change_position_size(
				relative_to: int, new_position: Vector2 = Vector2.ZERO,
				new_size: Vector2 = Vector2(100, 100), position_relative := false,
				size_relative := false, custom_time: Variant = null
			) -> void:
	var intended_size := anchor_targets[1] - anchor_targets[0]
	if size_relative: new_size += intended_size
	if new_size.x < RectContainer.custom_minimum_size.x: new_size.x = RectContainer.custom_minimum_size.x
	if new_size.y < RectContainer.custom_minimum_size.y: new_size.y = RectContainer.custom_minimum_size.y
	match relative_to:
		RELATIVE_TOP_LEFT:
			if position_relative: new_position += anchor_targets[0]
			anchor_targets[0] = new_position
		RELATIVE_TOP_RIGHT:
			if position_relative: new_position += anchor_targets[0] + intended_size.x * Vector2.RIGHT
			anchor_targets[0] = new_position - new_size.x * Vector2.RIGHT
		RELATIVE_BOTTOM_LEFT:
			if position_relative: new_position += anchor_targets[0] + intended_size.y * Vector2.DOWN
			anchor_targets[0] = new_position - new_size.y * Vector2.DOWN
		RELATIVE_BOTTOM_RIGHT:
			if position_relative: new_position += anchor_targets[1]
			anchor_targets[0] = new_position - new_size
		RELATIVE_CENTER:
			if position_relative: new_position += anchor_targets[0] + intended_size / 2.0
			anchor_targets[0] = new_position - new_size / 2.0

	anchor_targets[1] = anchor_targets[0] + new_size
	await TweenSize(custom_time)

func rotate_by(rot: float, relative := false, custom_time: Variant = null) -> void:
	var tw_r: PropertyTweener = create_tween().set_ease(EaseType).set_trans(TransType).tween_property(RectContainer, "rotation", rot, custom_time if custom_time else Duration)
	if relative: tw_r.as_relative()

func TweenSize(duration: Variant) -> void:
	if !duration:
		duration = Duration
	else:
		duration = duration as float
		if !duration: duration = Duration
	if tw and (tw.is_valid() and tw.is_running()):
		tw.stop()
		tw.chain()
	else:
		tw = create_tween().set_parallel().set_ease(EaseType).set_trans(TransType)
	tw.tween_property(RectContainer, "theme_override_constants/margin_left", anchor_targets[0].x, duration)
	tw.tween_property(RectContainer, "theme_override_constants/margin_top", anchor_targets[0].y, duration)
	tw.tween_property(RectContainer, "theme_override_constants/margin_right", 640- anchor_targets[1].x, duration)
	tw.tween_property(RectContainer, "theme_override_constants/margin_bottom", 480- anchor_targets[1].y, duration)
	tw.play()
	await tw.finished
	return
#endregion

#region webs
func clear_webs() -> void:
	for i: Node in Webs.get_children():
		Webs.remove_child(i)
		i.free()

## Set n = 0 to clear webs.
func set_webs(n: int, seperation: float = -1, margin: int = 15) -> void:
	clear_webs()
	if n < 1:
		return
	var _seperation: float = (current_size.y - 10 - margin) / n if seperation == -1 else seperation
	for i in n:
		var _w = web.instantiate() as Line2D
		Webs.add_child(_w)
		_w.position = Vector2(0, _seperation * i + 10 + margin)
	WebsArray = Webs.get_children()

func get_web_y_pos(id: int) -> float:
	if WebsArray.is_empty():
		push_error("Webs are empty, please use set_webs() to add them else the purple soul will break!")
		return 0
	id = clamp(id, 0, WebsArray.size() - 1)
	return Webs.get_child(id).global_position.y
#endregion
