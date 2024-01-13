extends Resource
class_name Item

@export var item_type := item_types.CONSUMABLE
@export var item_name := "TestItem"
@export_group("Weapon Stats")
@export var weapon_speed: float = 1.0
@export var weapon_bars: int = 1
@export var bar_trans_type := Tween.TRANS_CUBIC
@export var weapon_type := weapon_types.KNIFE
@export_group("Item Use Stats")
@export_multiline var use_message: PackedStringArray = ["* You used the Item!"]
@export_multiline var item_information: PackedStringArray = ["* Item - Heals 0 hp \n* This means this item has no description or is the default item."]
@export_multiline var throw_message: PackedStringArray = ["* You threw the Item!"]
@export_group("", "")
@export var heal_amount: int = 0
@export var attack_amount: int = 0
@export var defense_amount: int = 0
#{
	#"weaponspeed": 1.0,
	#"weaponbars": 1,
	#"bartranstype": Tween.TRANS_CUBIC,
	#"weapontype": Global.weaponstype.KNIFE,
	#"itemtype": Global.types.CONSUMABLE,
	#"name": "TestItem",
	#"use_message": ["item used!"],
	#"information": ["* Test Item - Heals 0 hp \n* This means this item has no description or is the default item."],
	#"heal": 0,
	#"attack": 0,
	#"defense": 0
#}
enum weapon_types {
	KNIFE,
	PUNCH,
	SHOE,
	BOOK,
	PAN,
	GUN
}

enum item_types {
	CONSUMABLE,
	WEAPON,
	ARMOR
}
