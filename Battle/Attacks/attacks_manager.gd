extends BackBufferCopy
class_name AttackManager

@onready var TopLeft = $Mask/TL
@onready var BottomRight = $Mask/BR
@onready var Mask = $Mask
@onready var Box = $/root/main/CoreElements/BattleBox

signal player_turn
var currentattacks: Array[Node]

signal remove_bullets

func add_attack(attack: PackedScene, starter: Enemy) -> Node:
	var attack_node = attack.instantiate()
	add_child(attack_node)
	currentattacks.append(attack_node)
	attack_node.attack_id = currentattacks.size() - 1
	attack_node.remove_attack.connect(end_attack)
	attack_node.enemy_attacker = starter
	return attack_node

func start_attack(id: int):
	currentattacks[id].start_attack()

func force_end_attacks():
	Box.reset_box()
	for i in currentattacks.size():
		currentattacks[i].queue_free()
	currentattacks.clear()
	emit_signal("player_turn")

func end_attack(id: int):
	currentattacks[id].queue_free()
	currentattacks[id] = null
	if check_all_attacks_finished():
		Box.reset_box()
		emit_signal("player_turn")

func check_all_attacks_finished():
	var finished := true
	for i in currentattacks.size():
		if currentattacks[i]:
			finished = false
	return finished

