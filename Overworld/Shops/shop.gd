extends CanvasLayer
class_name Shop

## Items Offered
@export var Offerings: Array[ShopItem] = [
	preload("res://Resources/ShopItems/ShopItemExample.tres")
]

## Price for items sold to shopkeeper.
@export var Sellferings: Array[ShopItem] = [

]

## Use this to set the dialogues to be used in KeeperDialogue after selecting a DialogueOptions.
@export var KeeperDialogues: Array[Dialogues] = [
	preload("res://Resources/Dialogues/KeeperDefault/default_shop.tres"),
	preload("res://Resources/Dialogues/KeeperDefault/default_shop.tres"),
	preload("res://Resources/Dialogues/KeeperDefault/default_shop.tres"),
	preload("res://Resources/Dialogues/KeeperDefault/default_shop.tres"),
	preload("res://Resources/Dialogues/KeeperDefault/default_shop.tres"),
]

## Use this to set the dialogue that shows on entering the shop.
@export var KeeperDefDialogue: Dialogues = preload("res://Resources/Dialogues/KeeperDefault/default_shop.tres")

## Use this to set shit for selling stuff:
@export var can_be_sold_to := true
@export var KeeperCannotSellDialogues: Dialogues = preload("res://Resources/Dialogues/KeeperDefault/default_shop_cannot_sell.tres")

@export var ExitNode: RoomEntranceNode
var soul_position: int = 0

const soul_positions := {
	0: [
		Vector2(38, 38),
		Vector2(0, 40),
	],
	1: [
		Vector2(52, 38),
		Vector2(0, 40),
	],
}
const InfoPanel := {
	true: Vector2(422, 40),
	false: Vector2(422, 250),
	"time": 0.6,
}

const KeeperBox := {
	false: Vector2(419, 239),
	true: Vector2(642, 239),
	"time": 0.3,
}

@onready var Rects: Array[NinePatchRect] = [$Control/Main, $Control/TextBox]
@onready var ItemsInfoBox: NinePatchRect = $Control/Info
@onready var ItemsInfo: RichTextLabel = $Control/Info/ItemInfo
@onready var Items: RichTextLabel = $Control/TextBox/Items
@onready var GoldInvInfo: Array[RichTextLabel] = [$Control/Main/Gold, $Control/Main/Space]
@onready var SellItems: RichTextLabel = $Control/TextBox/SellItems
@onready var DialogueOptions: RichTextLabel = $Control/TextBox/Dialogues
@onready var KeeperDialogue: GenericTextTyper = $Control/TextBox/MarginContainer/Dialogue
@onready var ItemSliderThing: ItemSlider = $Control/TextBox/Slider
@onready var Soul: Sprite2D = $Control/Main/Soul
@onready var Camera: CameraFx = $Camera

@onready var option_numbers: Array[int] = [
	3,
	DialogueOptions.text.split("\n").size() - 1,
	Offerings.size() - 1,
	Global.items.size() - 1,
]

enum States {
	SELECTING_ACTIONS = 0,
	SELECTING_DIALOGUE = 1,
	BUYING_ITEMS = 2,
	SELLING_ITEMS = 3,


	VIEWING_DIALOGUE,
}
var current_state := States.SELECTING_ACTIONS

func _ready() -> void:
	_in_state(States.SELECTING_ACTIONS)
	_refresh_g_info()

func _get_sell_items_count() -> int:
	var count: int = 0
	for item in Global.items:
		for offers in Sellferings:
			if item == offers.item:
				count += 1
	return count

func _get_sell_items(id: int, size: int = 4) -> String:
	var txt := ""
	var count: int = 0
	for item in Global.items:
		for offers in Sellferings:
			if item == offers.item:
				count += 1
				if count < id: continue
				txt += "%s - %sG\n" % [Global.item_list[item].item_name, offers.cost]
				if count >= size: return txt
				break
	return txt

func _write_sell_items(id: int) -> void:
	SellItems.text = _get_sell_items(id + 1)

func _write_shop_items() -> void:
	var txt := ""
	for i in Offerings.size():
		txt += "%sG - %s\n" % [Offerings[i].cost, Global.item_list[Offerings[i].item].item_name]
	Items.text = txt

func _in_state(new_state: States):
	current_state = new_state
	DialogueOptions.hide()
	KeeperDialogue.hide()
	SellItems.hide()
	ItemsInfo.hide()
	Soul.show()
	Items.hide()
	Soul.get_parent().remove_child(Soul)
	Rects[min(current_state, 1)].add_child(Soul)
	_set_item_panel()
	match new_state:
		States.SELECTING_ACTIONS:
			KeeperDialogue.show()
			_keeper_dialogue(KeeperDefDialogue)
			_set_soul_pos()
		States.BUYING_ITEMS:
			_write_shop_items()
			Items.show()
			_set_soul_pos()
		States.SELECTING_DIALOGUE:
			DialogueOptions.show()
			_set_soul_pos()
		States.VIEWING_DIALOGUE:
			_set_keeper_box()
			Soul.hide()
			KeeperDialogue.show()
		States.SELLING_ITEMS:
			SellItems.show()
			_write_sell_items(0)
			_set_soul_pos()

var tw: Tween
var tw2: Tween

func _set_item_panel():
	if tw and tw.is_valid(): tw.kill()
	tw = create_tween().set_trans(Tween.TRANS_EXPO)
	if current_state == States.BUYING_ITEMS:
		ItemsInfoBox.visible = true
	tw.tween_property(ItemsInfoBox, "position", InfoPanel[current_state == States.BUYING_ITEMS], InfoPanel.time)
	if current_state != States.BUYING_ITEMS:
		tw.tween_callback(ItemsInfoBox.set.bind("visible", false))
	_refresh_item_panel()


func _set_keeper_box():
	if tw2 and tw2.is_valid(): tw2.kill()
	tw2 = create_tween().set_trans(Tween.TRANS_CUBIC).set_parallel()
	if current_state == States.VIEWING_DIALOGUE:
		tw2.tween_property(Rects[0], "modulate:a", float(current_state != States.VIEWING_DIALOGUE), KeeperBox.time)
	tw2.tween_property(Rects[1], "size", KeeperBox[current_state == States.VIEWING_DIALOGUE], KeeperBox.time)
	if current_state != States.VIEWING_DIALOGUE:
		tw2.tween_property(Rects[0], "modulate:a", float(current_state != States.VIEWING_DIALOGUE), KeeperBox.time)


func _refresh_item_panel():
	ItemsInfo.visible = current_state == States.BUYING_ITEMS
	if ItemsInfo.visible:
		ItemsInfo.text = Global.item_list[Offerings[soul_position].item].item_information[0]


func _refresh_g_info(red := false):
	GoldInvInfo[0].text = "%sG" % [Global.player_gold]
	GoldInvInfo[1].text = "%s%s/8" % ["[color=red]" if red else "", str(Global.items.size())]


signal keeper_expression(exp: Array)

func _keeper_dialogue(dialogues: Dialogues):
	KeeperDialogue.type_text.call_deferred(dialogues.get_dialogues_single(Dialogues.DIALOGUE_TEXT))
	var expressions := dialogues.get_dialogues_single(Dialogues.DIALOGUE_EXPRESSIONS)
	for i in dialogues.dialogues.size():
		await KeeperDialogue.started_typing
		keeper_expression.emit(expressions[i])

func _keeper_dialogue_temp(dialogues: Dialogues, return_state: States):
	_in_state(States.VIEWING_DIALOGUE)
	await _keeper_dialogue(dialogues)
	await KeeperDialogue.finished_all_texts
	get_viewport().set_input_as_handled()
	_in_state(return_state)
	_set_keeper_box()


func _set_soul_pos() -> void:
	if current_state == States.SELLING_ITEMS:
		_write_sell_items(soul_position)
		ItemSliderThing.value = soul_position
	ItemSliderThing.visible = current_state == States.SELLING_ITEMS
	if current_state == States.BUYING_ITEMS:
		_refresh_item_panel()
	var pos_info: Array = soul_positions[min(current_state, 1)]
	Soul.position = pos_info[0] + pos_info[1] * (soul_position if current_state != States.SELLING_ITEMS else 0)

func _exit() -> void:
	await Camera.blind(1)
	ExitNode.force_enter()


func _unhandled_input(event: InputEvent) -> void:
	if current_state < States.VIEWING_DIALOGUE:
		if event.is_action_pressed("ui_down") and soul_position < option_numbers[current_state]:
			soul_position += 1
			$select.play()
			_set_soul_pos()
		if event.is_action_pressed("ui_up") and soul_position > 0:
			soul_position -= 1
			$select.play()
			_set_soul_pos()
		if event.is_action_pressed("ui_cancel"):
			match current_state:
				States.BUYING_ITEMS:
					soul_position = 0
					_in_state(States.SELECTING_ACTIONS)
					_refresh_g_info()
				States.SELECTING_DIALOGUE:
					soul_position = 2
					_in_state(States.SELECTING_ACTIONS)
				States.SELLING_ITEMS:
					soul_position = 1
					_in_state(States.SELECTING_ACTIONS)


		if event.is_action_pressed("ui_accept"):
			match current_state:
				States.SELECTING_ACTIONS:
					KeeperDialogue.kill_tweens(true)
					match soul_position:
						0:
							soul_position = 0
							_in_state(States.BUYING_ITEMS)
						1:
							if can_be_sold_to and Global.items.size() > 0 and _get_sell_items_count() > 0:
								soul_position = 0
								option_numbers[3] = _get_sell_items_count() - 1
								_in_state(States.SELLING_ITEMS)
							else:
								_keeper_dialogue_temp(KeeperCannotSellDialogues, States.SELECTING_ACTIONS)
						2:
							soul_position = 0
							_in_state(States.SELECTING_DIALOGUE)
						3:
							_exit()
				States.SELECTING_DIALOGUE:
					_keeper_dialogue_temp(KeeperDialogues[soul_position], States.SELECTING_DIALOGUE)
				States.BUYING_ITEMS:
					if Global.player_gold >= Offerings[soul_position].cost and Global.items.size() < 8:
						Global.player_gold -= Offerings[soul_position].cost
						Global.items.append(Offerings[soul_position].item)
						$bought.play()
						_refresh_g_info()
					else:
						$insufficient.play()
						if Global.items.size() >= 8:
							_refresh_g_info(true)
				States.SELLING_ITEMS:
					if Global.items.size() > soul_position and Global.items[soul_position] >= 0:
						Global.items.remove_at(soul_position)
						_refresh_g_info()
						$bought.play()
						option_numbers[3] = _get_sell_items_count() - 1
						if soul_position > option_numbers[3]:
							soul_position = option_numbers[3]
						_set_soul_pos()
						_write_sell_items(soul_position)
						if !_get_sell_items_count():
							soul_position = 1
							_in_state(States.SELECTING_ACTIONS)


