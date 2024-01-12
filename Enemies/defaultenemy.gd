extends Enemy
class_name sans_demo

@onready var Dialogue = $Dialogue
var time = 0.1

@onready var AnimStates : AnimationNodeStateMachinePlayback = $States.get("parameters/playback")
@onready var body = $Sprites/Idle/body
@onready var head = $Sprites/Idle/body/head
@onready var sweat = $Sprites/Idle/body/head/sweat

@onready var throw_sweat = $Sprites/Throw/head/sweat
@onready var throw_head = $Sprites/Throw/head

var speech_texts = [
	["your mother.",
	"btw, green still gives u karma \nxd!",
	"what?",
	"mad?",
	"heh..."],
	["wow, my codeword",
	"so kid...",
	"i'll give ya a chance.",
	"spare me now..."]
]
var speech_expressions = [
		[
			[0,0],
			[15,0],
			[1,0],
			[2,1],
			[3,0],
			[0,0],
		],[
			[4,0],
			[2,0],
			[6,1],
			[5,0]
		]
		
]

var animations = {
	"throw_left":Vector2.LEFT,
	"throw_right":Vector2.RIGHT,
	"throw_down":Vector2.DOWN,
	"throw_up":Vector2.UP
}

func _on_get_turn():
	Soul.mode = Soul.DISABLE_MOVEMENT
	Box.change_size(Vector2(-200,0),true)
	if not enemy_states[current_state].Sparable:
		await Dialogue.DialogueText(speech_texts[0],speech_expressions[0])
		Soul.mode = Soul.RED
		Attacks.start_attack(default_attack,self)
	else:
		await Dialogue.DialogueText(speech_texts[1],speech_expressions[1])
		Attacks.end_attacks()

func set_expression(exp_id):
	head.frame = exp_id[0]
	body.frame = exp_id[1]

func throw(dir:Vector2 = Vector2.DOWN):
	AnimStates.stop()
	AnimStates.travel(animations.find_key(dir))
	throw_head.play("crazy",true)
	await get_tree().create_timer(0.3,false).timeout
	Soul.set_gravity_direction(Vector2.DOWN,true)
	Soul.gravity_multiplier = 10
	await get_tree().create_timer(0.4,false).timeout
	throw_head.animation = "heads"

func on_fight_used():
	print("0")
	change_state(0)

func on_act_used(option):
	if option == 3:
		change_state(1)

func on_mercy_used():
	if enemy_states[current_state].Sparable:
		emit_signal("spared",id)

