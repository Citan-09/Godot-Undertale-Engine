extends Enemy
class_name sans_demo

@onready var dialogue: DialogueControl = $Dialogue
var time: float = 0.1

@onready var AnimStates: AnimationNodeStateMachinePlayback = $States.get("parameters/playback")
@onready var body: AnimatedSprite2D = $Sprites/Idle/body
@onready var head: AnimatedSprite2D = $Sprites/Idle/body/head
@onready var sweat: AnimatedSprite2D = $Sprites/Idle/body/head/sweat

@onready var throw_sweat: AnimatedSprite2D = $Sprites/Throw/head/sweat
@onready var throw_head: AnimatedSprite2D = $Sprites/Throw/head
@onready var throw_timer: Timer = $Timer

var animations := {
	"throw_left": Vector2.LEFT,
	"throw_right": Vector2.RIGHT,
	"throw_down": Vector2.DOWN,
	"throw_up": Vector2.UP
}

var attack: PackedScene = preload("res://Battle/Attacks/default_attack.tscn")
var attack_spare: PackedScene = preload("res://Battle/Attacks/attack_nothing.tscn")

func _on_get_turn() -> void:
	Box.change_size(Vector2(350, 140))
	if not enemy_states[current_state].Sparable:
		var a := Attacks.add_attack(attack)
		a.connect(&"throw", throw)
		await dialogue.DialogueText(dialogues[0])
		Soul.mode = Soul.RED
		a.start_attack()  # Method ran to start attack (use any other method if you want for some reason.)
	else:
		var a := Attacks.add_attack(attack_spare)
		a.connect(&"throw", throw)
		await dialogue.DialogueText(dialogues[1])
		a.start_attack()  # Method ran to start attack (use any other method if you want for some reason.)

func _set_expression(exp_id: Array) -> void:
	head.frame = exp_id[0]
	body.frame = exp_id[1]

func throw(dir: Vector2 = Vector2.DOWN) -> void:
	throw_timer.start()
	AnimStates.stop()
	AnimStates.travel(animations.find_key(dir))
	throw_head.play("crazy", true)
	await get_tree().create_timer(0.25, false).timeout
	Soul.set_gravity_direction(dir, true)
	for i in 5: await get_tree().process_frame
	Soul.gravity_multiplier = 10

func end_throw() -> void:
	throw_head.animation = "heads"

func on_fight_used() -> void:
	change_state(0)

func on_act_used(option: int) -> void:
	if option == 3:
		change_state(1)
		dodging = false
		stats.def = -50

func on_mercy_used() -> void:
	if enemy_states[current_state].Sparable:
		emit_signal("spared", id)

func on_defeat() -> void:
	Global.set_flag("SANS_FOUGHT", true)

