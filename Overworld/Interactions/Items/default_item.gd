extends Node2D

@export var no_item_text: PackedStringArray = [
	"There is nothing here."
]
var txtbox := preload("res://Overworld/text_box.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Global.flags.get("PICKED_UP_TEST_ITEM", false):
		$PickupInteractArea.disable_item()
		$InteractArea.enable()



func _on_pickup_interact_area_took_item() -> void:
	Global.set_flag("PICKED_UP_TEST_ITEM", true)
	$PickupInteractArea.disable_item()
	$InteractArea.enable()


func _on_interact_area_interacted() -> void:
	var _t := txtbox.instantiate() as TextBox
	add_child(_t)
	_t.generic(Dialogues.new().from(no_item_text))
