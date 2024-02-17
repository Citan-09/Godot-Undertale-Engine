extends Node2D
class_name BattleMain

@onready var Camera: CameraFx = %Camera
@onready var Buttons: BattleButtons = %Buttons
@onready var Box: BattleBox = %BattleBox
@onready var Enemies: Node2D = %Enemies

var attack: PackedScene = preload("res://Battle/AttackMeter/meter.tscn")
var slash: PackedScene = preload("res://Battle/Slashes/slashes.tscn")
var damageinfo: PackedScene = preload("res://Battle/AttackMeter/damage.tscn")
## Background
@onready var Bg: Background = $Background
## Seperate Soul for menu.
@onready var Soul_Menu: SoulMenu = %Soul_Menu
## Seperate Soul for Battle Box.
@onready var Soul_Battle: SoulBattle = %Soul_Battle
## Attacks Handler (NOT THE CURRENT ATTACK).
@onready var Attacks: AttackManager = %BoxClipper
## Attacks Handler (NOT THE CURRENT ATTACK).
@onready var AttacksParent: Node = %Attacks
## Battle HUD (Name, Hp, Kr, etc).
@onready var HUD: BattleHUD = %HUD

## Turn Number, increases every time the enemy gets their turn.
var TurnNumber := 0
## Default Encounter Resource used to play music and set enemies and more.
@export var encounter: Encounter

## Temporary rewards used to grant rewards at the end of the battle.
var rewards := {"gold": 0, "exp": 0}
## Cache enemy names.
var enemynames := []
## Cache enemy Nodes.
var enemies: Array[Enemy] = []
## Cache enemies
var enemieshp := []
## Cache enemy's max hp only.
var enemiesmaxhp := []

## music that gets cached when loading enemies.
var music: AudioStream
@onready var music_player: AudioStreamPlayer = Global.Music

## True if any enemy has kr enabled
var kr := false
## Signal to connect the Damage Info (HP Bar and Damage Info)'s finish signal to miss() and hit().
signal damage_info_finished
## Used to start enemies' turn (after all actions have been processed).
signal end_turn

signal item_used(id: int)
signal spare_used

## Handles resettings Battle Box's ActionMemory and puts your soul into the Battle Box
func _on_player_turn_start() -> void:
	Soul_Battle.disable()
	Box.add_child(Soul_Menu, true)
	Box.move_child(Soul_Menu, 3)
	Buttons.enable()
	Box.blitter_flavour()

func _on_enemy_turn_start() -> void:
	TurnNumber += 1
	Box.add_child(Soul_Battle, true)
	Box.move_child(Soul_Battle, 3)

func _ready() -> void:
	Bg.texture_rect.texture = encounter.background
	var enemy_scenes: Array[PackedScene] = encounter.enemies
	enemynames = enemy_scenes
	for i in enemy_scenes.size():
		var enemy: Node = enemy_scenes[i].instantiate()
		Enemies.add_child(enemy, true)
		if enemy_scenes.size() == 2:
			enemy.position.x = -100 if i == 0 else 100
		if enemy_scenes.size() == 3 and i != 1:
			enemy.position.x = -200 if i == 0 else 200

	for enemy in Enemies.get_children():
		enemies.append(enemy)
	assert(null not in enemies, "Error, value \"null\" was found in enemies (Array)")
	Box.setenemies(enemies)
	for i in enemies.size():
		if enemies.size() > 1:
			enemies[i].solo = false
		if enemies[i].kr:
			kr = true
			HUD.set_kr()
		enemies[i].id = i
		enemies[i].changed_state.connect(Box.set_targets)
		enemieshp.append(enemies[i].stats.get("hp", 0))
		enemiesmaxhp.append(enemies[i].stats.get("max_hp", 1))
		Box.BlitterText.flavour_texts.append_array(enemies[i].flavour_text if enemies[i].flavour_text else (["* %s approaches!" % enemies[i].enemy_name] as PackedStringArray))
		# REWARDS (add more if needed)
		var rwrds: Dictionary = enemies[i].rewards if enemies[i].rewards else {}
		rewards["gold"] += rwrds.get("gold", 0)
		rewards["exp"] += rwrds.get("exp", 0)
		# END
		music = encounter.music

		item_used.connect(enemies[i].on_item_used)
		spare_used.connect(enemies[i].on_mercy_used)

		enemies[i].spared.connect(spare_enemy)
		end_turn.connect(enemies[i]._on_get_turn)

	Buttons.enable()
	Soul_Battle.get_parent().remove_child(Soul_Battle)
	music_player.stream = music
	music_player.play()
	Box.ActionMemory[0] = Box.State.Blittering
	Box.blitter_flavour()
	Box.TL.remote_path = Box.TL.get_path_to(Attacks.TopLeft)
	Box.BR.remote_path = Box.TL.get_path_to(Attacks.BottomRight)

	_initialize()


## Initialize anything here (runs after ready and setting enemies)
func _initialize() -> void:
	Camera.blinder.modulate.a = 1
	Camera.blind(0.5, 0)


func _act(target: int, option: int) -> void:
	enemies[target].on_act_used(option)
	end_turn.emit()

func _mercy(choice: int) -> void:
	match choice:
		-1:
			end_turn.emit()
		0:
			for i in enemies.size():
				if enemies[i]:
					enemies[i].on_mercy_used()
			if not check_end_encounter():
				end_turn.emit()
		1:
			await Camera.blind(1, 1)
			Global.temp_atk = 0
			Global.temp_def = 0
			OverworldSceneChanger.load_cached_overworld_scene()

func _item(item_id: int) -> void:
	for e: Enemy in enemies:
		e.on_item_used(item_id)
	end_turn.emit()

# region fight_logic
##Creates the attack meter and handles damaging enemies and showing damage with hit() and miss().
func _fight(target: int) -> void:
	var clone: Node = attack.instantiate()
	clone.target = target
	clone.damagetarget.connect(hit)
	clone.missed.connect(miss)
	Box.add_child(clone, true)
	clone.targetdef = enemies[target].stats.get("def", 0)

## Used when the bar doesn't miss (NOT FOR BLOCKING).
func hit(damage: int, target: int, crit := false) -> void:
	var slashes: Slash = slash.instantiate() as Slash
	slashes.crit = crit
	Box.add_child(slashes, true)
	slashes.global_position = enemies[target].sprites.global_position
	if enemies[target].dodging:
		slashes.started.connect(enemies[target].dodge)
	await slashes.finished
	damage = floor(damage * slashes.dmg_mult)

	var clone: Node = damageinfo.instantiate()
	clone.connect("damagetarget", enemies[target]._hurt)
	clone.global_position = slashes.global_position
	clone.hp = enemieshp[target]
	clone.max_hp = enemiesmaxhp[target]
	if enemies[target].dodging:
		clone.miss = true
	else:
		clone.damage = damage
		enemieshp[target] -= damage
	Box.add_child(clone, true)
	clone.finished.connect(emit_signal.bind("damage_info_finished"))
	await clone.finished
	@warning_ignore("redundant_await")
	await enemies[target].on_fight_used()
	Box.disable()
	if enemieshp[target] < 0.0:
		enemies[target].on_death()
		kill_enemy(target)
	else:
		end_turn.emit()


## Used when you miss (for dodging as well).
func miss(target: int) -> void:
	var clone: Node = damageinfo.instantiate()
	clone.global_position = enemies[target].sprites.global_position
	clone.hp = enemieshp[target]
	clone.max_hp = enemiesmaxhp[target]
	clone.miss = true
	Box.add_child(clone)
	clone.finished.connect(emit_signal.bind("damage_info_finished"))
	await clone.finished
	end_turn.emit()
# endregion

## Kills enemy and checks if the encounter can end.
func kill_enemy(enemy_id: int = 0) -> void:
	enemies[enemy_id].on_defeat()
	enemies[enemy_id].script = null
	enemies[enemy_id] = null
	enemynames[enemy_id] = null
	Box.setenemies(enemies)
	Box.disable()
	if check_end_encounter():
		end_encounter()
	else:
		var _solo := check_enemy_solo()
		for i in enemies.size():
			if enemies[i] == null:
				continue
			enemies[i].solo = _solo
		end_turn.emit()


func check_enemy_solo() -> bool:
	var enemy_count: int = 0
	for i in enemies.size():
		if enemies[i]:
			enemy_count += 1
	return enemy_count == 1



func check_end_encounter() -> bool:
	var empty := true
	for i in enemies.size():
		if enemies[i -1] or enemies[i]:
			empty = false
	return empty

## Spares enemy and checks if the encounter can end.
func spare_enemy(enemy_id: int = 0) -> void:
	rewards["exp"] -= enemies[enemy_id].rewards.get("exp", 0)
	enemies[enemy_id].on_defeat()
	enemies[enemy_id].sprites.modulate.a = 0.5
	enemies[enemy_id].script = null
	enemies[enemy_id] = null
	enemynames[enemy_id] = null
	Box.setenemies(enemies)
	if check_end_encounter():
		end_encounter()
	else:
		var _solo := check_enemy_solo()
		for i in enemies.size():
			if enemies[i]:
				enemies[i].solo = _solo
		end_turn.emit()

const Magnitudes := {
	0.00_000_000_1: "n",
	0.00_000_1: "u",
	0.00_1: "m",
	1: "",
	1_000: "k",
	1_000_000: "M",
	1_000_000_000: "B",
}

func pure_int_to_short_representation(input: int) -> String:
	var highest = 1
	var keys := Magnitudes.keys()
	for i in keys.size():
		if input >= keys[i]: highest = keys[i]
	input /= highest
	return "%s%s" % [round(float(str(input).left(4))), Magnitudes[highest]]

## Ends encounter and gives rewards.
func end_encounter() -> void:
	music_player.stop()
	# REWARDS again (add here too)
	Global.player_gold += rewards["gold"]
	Global.player_exp += rewards["exp"]
	var wintxt := Box.wintext
	wintxt = wintxt % [pure_int_to_short_representation(rewards["exp"]), pure_int_to_short_representation(rewards["gold"])]
	if Global.check_level_up():
		wintxt += " \n* Your Love increased!"
		$lvlup.play()
	await get_tree().process_frame
	Box.change_state(Box.State.Blittering)
	Box.BlitterText.typetext(wintxt)
	await Box.BlitterText.finished_all_texts
	await Camera.blind(1, 1)
	Global.temp_atk = 0
	Global.temp_def = 0
	Soul_Battle.queue_free()
	Soul_Menu.queue_free()
	OverworldSceneChanger.load_cached_overworld_scene()

