@icon("res://Enemies/enemyicon.png")
extends CharacterBody2D
class_name Enemy

@onready var hurt_sound: Node = get_node(hurt_sound_path)
@onready var dust_sound: Node = get_node(dust_sound_path)
@onready var dust: GPUParticles2D = get_node(dust_path)
@onready var Main: BattleMain = Global.scene_container.current_scene
@onready var Attacks: AttackManager = Main.Attacks
@onready var NonMask: Node = Main.AttacksParent
@onready var Camera: CameraRemoteController = Main.Camera
@onready var Box: BattleBox = Main.Box
@onready var Soul: SoulBattle = Main.Soul_Battle

var kr: bool = true

##USED FOR THE BATTLE SYSTEM THIS IS NOT AN ID USED TO LOAD THEM
var id: int
var solo := true
signal changed_state
signal spared(id_number: int)

@export var enemy_name := "Enemy"
@export_group("Battle Info")
## Enables/Disable giving different act options depending on the state of the enemy.
@export var change_act_infos: bool = true
@export var dodging: bool = false
@export var stats := {
	"def": 10,
	"hp": 100,
	"max_hp": 100,
	"kr": true
}

@export var dialogues: Array[Dialogues] = []

@export_multiline var flavour_text: PackedStringArray

@export var rewards := {
				"exp": 10,
				"gold": 10
			}

@export_group("Acting States")
## new states override old ones. (this means the number of acts are at least the number in state 0.)
@export var new_states_override: bool = true
## only works if new states override.
@export var one_by_one_overrdie: bool = true
@export var enemy_states: Array[EnemyState] = [
]

@export_group("Enemy Elements")
@export_node_path("AudioStreamPlayer") var hurt_sound_path := ^"Sounds/Hurt"
@export_node_path("AudioStreamPlayer") var dust_sound_path := ^"Sounds/Dust"
@export_node_path("Node2D") var sprites_path := ^"Sprites"
@export_node_path("GPUParticles2D") var dust_path := ^"Dust"
@onready var sprites: Node = get_node(sprites_path)

var current_state: int = 0

func _init() -> void:
	spared.connect(_on_spared)

var _info: ActInfo

func get_act_info(act_choice: int) -> ActInfo:
	if new_states_override:
		if one_by_one_overrdie:
			_get_act(0,act_choice)
			for i in current_state + 1:
				_get_act(i, act_choice)
		else:
			_get_act(current_state,act_choice)
	else:
		_get_act(current_state,act_choice)
	var __info := _info
	_info = null
	return __info

func _get_act(state: int,option: int) -> void:
	if enemy_states[state].Acts.size() > option:
		_info = enemy_states[state].Acts[option]


func change_state(new_state: int) -> void:
	current_state = new_state
	changed_state.emit()

func dodge() -> void:
	var tw := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	var rand_sign := (randi_range(0, 1) * 2) - 1
	tw.tween_property(sprites, "position:x", rand_sign * 120, 0.4).as_relative()
	tw.tween_property(sprites, "position:x", 0, 0.4).as_relative().set_delay(0.8)

func _hurt(_amt: int) -> void:
	var defaultpos: float = sprites.position.x
	var hurtsoundtween := create_tween()
	hurtsoundtween.tween_callback(hurt_sound.play).set_delay(0.4)
	var tw := create_tween().set_loops(6)
	tw.tween_property(sprites, "position:x", -4, 0.02).as_relative()
	tw.tween_interval(0.02)
	tw.tween_property(sprites, "position:x", 4, 0.02).as_relative()
	tw.tween_interval(0.02)
	await tw.finished
	tw = create_tween()
	tw.tween_property(sprites, "position:x", defaultpos, 0.03)


func on_fight_used() -> void:
	pass  # DO THE STUFF HERE

func on_act_used(_option: int) -> void:
	pass  # DO THE STUFF HERE

func on_item_used(_option: int) -> void:
	pass  # DO THE STUFF HERE

func on_mercy_used() -> void:
	pass  # DO THE STUFF HERE

func _on_get_turn() -> void:
	pass

func on_death() -> void:
	var tween := create_tween().set_parallel()#.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(sprites, "modulate:a", 0, dust.lifetime / 4.0)
	tween.tween_property(dust.process_material, "shader_parameter/progress", 1, dust.lifetime).from(0.0)
	dust.restart()
	dust.emitting = true
	dust_sound.play()

func _on_spared(_id: int) -> void:
	$Spare.restart()
	$Spare.emitting = true
	$Sounds/Dust.play()

func on_defeat() -> void:
	pass
