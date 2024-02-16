class_name BattleBoxBehaviour extends Node

@export var BoxPath: NodePath = ^"../.."
@onready var Box: BattleBox = get_node(BoxPath)

signal change_state(new_state: BattleBox.State)

var enabled := false

func gain_control() -> void:
	enabled = true
	_on_gain_control()

func _on_gain_control() -> void:
	pass

func lose_control() -> void:
	enabled = false
	_on_lose_control()

func _on_lose_control() -> void:
	pass

func _input(event: InputEvent) -> void:
	if !enabled:
		return
	input(event)

@warning_ignore("unused_parameter")
func input(event: InputEvent) -> void:
	pass


@warning_ignore("unused_parameter")
func _on_changed_state(new_state: BattleBox.State) -> void:
	pass
