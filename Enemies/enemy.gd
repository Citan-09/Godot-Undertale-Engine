@icon("res://Enemies/enemyicon.png")
extends CharacterBody2D
class_name Enemy

@onready var hurt_sound = get_node(hurt_sound_path)
@onready var dust_sound = get_node(dust_sound_path)
@onready var dust :GPUParticles2D = get_node(dust_path)
@onready var Attacks :AttackManager = $/root/main/Attacks/BoxClipper
@onready var Main :BattleMain = $/root/main
@onready var NonMask = $/root/main/Attacks
@onready var Mask = $/root/main/Attacks/BoxClipper/Mask
@onready var Camera = $/root/main/Camera
@onready var Box :BattleBox = $/root/main/CoreElements/BattleBox
@onready var Soul :SoulBattle = $/root/main/Soul_Battle
@onready var MenuSoul = $/root/main/Soul_Battle

var default_attack = preload("res://Battle/Attacks/default_attack.tscn")

var kr: bool = true

##USED FOR THE BATTLE SYSTEM THIS IS NOT AN ID USED TO LOAD THEM
var id
var solo = true
signal changed_state(which,newstate,color)
signal spared(id_number)

@export var enemy_name := "defaultenemy"
@export_group("Battle Info")
## Enables/Disable giving different act options depending on the state of the enemy.
@export var change_act_infos :bool = true
@export var dodging :bool = false
@export var stats ={
	"def": 10,
	"hp": 100,
	"max_hp": 100,
	"kr": true
}
@export var flavour_text :Array[String] = [
				"* Test123",
				"* This is a default_enemy"
			]
@export var rewards :Dictionary = {
				"exp":10,
				"gold":10
			}

@export_group("Acting States")
## new states override old ones. (this means the number of acts are at least the number in state 0.)
@export var new_states_override : bool = true
## only works if new states override.
@export var one_by_one_overrdie : bool = true
@export var enemy_states : Array[EnemyState]= [
	
]
@export_group("Enemy Elements")
@export_node_path("AudioStreamPlayer") var hurt_sound_path = ^"Sounds/Hurt"
@export_node_path("AudioStreamPlayer") var dust_sound_path = ^"Sounds/Dust"
@export_node_path("Node2D") var sprites_path = ^"Sprites"
@export_node_path("GPUParticles2D") var dust_path = ^"$Dust"
@onready var sprites = get_node(sprites_path)

var current_state : int = 0

func _init():
	spared.connect(_on_spared)
func get_act_info(act_choice : int) -> Act:
	var _info
	if not change_act_infos: act_choice = 0
	if new_states_override:
		if enemy_states[0].Acts.size() > act_choice:
			_info = enemy_states[0].Acts[act_choice]
			if one_by_one_overrdie:
				_info = enemy_states[current_state].Acts[act_choice]
				for i in current_state:
					_info = enemy_states[i].Acts[act_choice]
			elif enemy_states[current_state].Acts[act_choice]:
				_info = enemy_states[current_state].Acts[act_choice]
	else:
		_info = enemy_states[current_state].Acts[act_choice]
	return _info

func change_state(new_state : int):
	current_state = new_state
	var name_color = Color.WHITE
	if enemy_states[new_state].Sparable:
		name_color = Color.YELLOW
	emit_signal("changed_state")

func dodge():
	var tw = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	var rand_sign = (randi_range(0,1) * 2) -1
	tw.tween_property(sprites,"position:x", rand_sign * 120,0.4).as_relative()
	tw.tween_property(sprites,"position:x", 0,0.4).as_relative().set_delay(0.8)

func _hurt(amt:int):
	var defaultpos = sprites.position.x
	var hurtsoundtween = create_tween()
	hurtsoundtween.tween_callback(hurt_sound.play).set_delay(0.4)
	var tw = create_tween().set_loops(6)
	tw.tween_property(sprites,"position:x",-4,0.02).as_relative()
	tw.tween_interval(0.02)
	tw.tween_property(sprites,"position:x",4,0.02).as_relative()
	tw.tween_interval(0.02)
	await tw.finished
	tw = create_tween()
	tw.tween_property(sprites,"position:x",defaultpos,0.03)
	

func on_fight_used():
	pass # DO THE STUFF HERE

func on_act_used(option):
	pass # DO THE STUFF HERE

func on_item_used(option):
	pass # DO THE STUFF HERE

func on_mercy_used():
	pass # DO THE STUFF HERE

func _on_get_turn():
	pass

func on_death():
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel()
	tween.tween_property(sprites,"modulate:a",0,dust.lifetime)
	dust.restart()
	dust.emitting = true
	dust_sound.play()

func _on_spared(_id):
	$Spare.restart()
	$Spare.emitting = true
	$Sounds/Dust.play()
