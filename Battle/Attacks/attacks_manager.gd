extends BackBufferCopy
class_name AttackManager

@onready var TopLeft: Sprite2D = $Mask/TL
@onready var BottomRight: Sprite2D = $Mask/BR
@onready var Mask: Node2D = $Mask
signal player_turn
var current_attacks: Array[Node]


func add_attack(attack: PackedScene) -> Node:
	var attack_node: Node = attack.instantiate()
	add_child(attack_node, true)
	current_attacks.append(attack_node)
	attack_node.attack_id = current_attacks.size() - 1
	attack_node.remove_attack.connect(end_attack)
	return attack_node

func start_attack(id: int) -> void:
	current_attacks[id].start_attack()

func force_end_attacks() -> void:
	for i in current_attacks.size():
		current_attacks[i].queue_free()
	current_attacks.clear()
	player_turn.emit()

func end_attack(id: int) -> void:
	current_attacks[id].queue_free()
	current_attacks[id] = null
	if check_all_attacks_finished():
		player_turn.emit()

func check_all_attacks_finished() -> bool:
	var finished := true
	for i in current_attacks.size():
		if current_attacks[i]:
			finished = false
	return finished

