extends BackBufferCopy
class_name AttackManager

@onready var TopLeft: Sprite2D = $Mask/TL
@onready var BottomRight: Sprite2D = $Mask/BR
@onready var Mask: Node2D = $Mask
#@onready var Box: BattleBox = %BattleBox

signal player_turn
var currentattacks: Array[Node]

signal remove_bullets

func add_attack(attack: PackedScene, starter: Enemy) -> Node:
	var attack_node: Node = attack.instantiate()
	add_child(attack_node, true)
	currentattacks.append(attack_node)
	attack_node.attack_id = currentattacks.size() - 1
	attack_node.remove_attack.connect(end_attack)
	attack_node.enemy_attacker = starter
	return attack_node

func start_attack(id: int) -> void:
	currentattacks[id].start_attack()

func force_end_attacks() -> void:
	for i in currentattacks.size():
		currentattacks[i].queue_free()
	currentattacks.clear()
	player_turn.emit()

func end_attack(id: int) -> void:
	currentattacks[id].queue_free()
	currentattacks[id] = null
	if check_all_attacks_finished():
		player_turn.emit()

func check_all_attacks_finished() -> bool:
	var finished := true
	for i in currentattacks.size():
		if currentattacks[i]:
			finished = false
	return finished

