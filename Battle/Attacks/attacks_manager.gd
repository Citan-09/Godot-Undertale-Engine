extends BackBufferCopy
class_name AttackManager

@onready var TopLeft = $Mask/TL
@onready var BottomRight = $Mask/BR
@onready var Mask = $Mask
@onready var Box = $/root/main/CoreElements/BattleBox

signal player_turn
var currentattacks :Array[Node]

func start_attack(attack:PackedScene,starter:Enemy):
	var attack_node= attack.instantiate()
	add_child(attack_node)
	currentattacks.append(attack_node)
	attack_node.connect("remove_bullets",end_attacks)
	attack_node.enemy_attacker = starter
	attack_node.start_attack()

func end_attacks():
	Box.reset_box()
	for i in currentattacks.size():
		currentattacks[i].queue_free()
	currentattacks.clear()
	emit_signal("player_turn")
	
