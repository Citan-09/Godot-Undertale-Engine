extends Node2D
## Main battle logic. Also sets bullet masks.
class_name BattleMain

@onready var Camera: CameraFx = $Camera
@onready var Buttons = $CoreElements/Buttons
@onready var Box: BattleBox = $CoreElements/BattleBox
@onready var Enemies = $CoreElements/Enemies

var attack: PackedScene = preload("res://Battle/AttackMeter/meter.tscn")
var slash: PackedScene = preload("res://Battle/Slashes/slashes.tscn")
var damageinfo: PackedScene = preload("res://Battle/AttackMeter/damage.tscn")
## Seperate Soul for menu.
@onready var Soul_Menu: SoulMenu = $Soul_Menu
## Seperate Soul for Battle Box.
@onready var Soul_Battle: SoulBattle = $Soul_Battle
## Attacks Handler (NOT THE CURRENT ATTACK).
@onready var Attacks: AttackManager = $Attacks/BoxClipper
## Battle HUD (Name, Hp, Kr, etc).
@onready var HUD: BattleHUD = $CoreElements/HUD

## Turn Number, increases every time the enemy gets their turn.
var TurnNumber := 0
## Default Encounter Resource used to play music and set enemies and more.
@export var encounter: Encounter

## Temporary rewards used to grant rewards at the end of the battle.
var rewards = {"gold": 0, "exp": 0}
## Cache enemy names.
var enemynames := []
## Cache enemy Nodes.
var enemies := []
## Cache enemies
var enemieshp := []
## Cache enemy's max hp only.
var enemiesmaxhp := []

## music that gets cached when loading enemies.
var music

## True if any enemy has kr enabled
var kr := false
## Signal to connect the Damage Info (HP Bar and Damage Info)'s finish signal to miss() and hit().
signal damage_info_finished
## Used to start enemies' turn (after all actions have been processed).
signal endturn

signal item_used(id: int)
signal spare_used

## Handles resettings Battle Box's ActionMemory and puts your soul into the Battle Box
func _on_player_turn_start():
	Soul_Battle.disable()
	add_child(Soul_Menu, true)
	move_child(Soul_Menu, 6)
	Buttons.enable()
	Box.ActionMemory[0] = Box.state.Blittering
	Box.Blitter.show()
	Box.Blittertext.blitter(TurnNumber)

func _on_enemy_turn_start():
	TurnNumber += 1
	add_child(Soul_Battle, true)
	move_child(Soul_Battle, 6)

func _ready() -> void:
	enemies.append_array(encounter.enemies)
	enemynames = enemies
	for i in enemies.size():
		var enemy = enemies[i].instantiate()
		Enemies.add_child(enemy, true)
		if enemies.size() == 2:
			enemy.position.x = -100 if i == 0 else 100
		if enemies.size() == 3 and i != 1:
			enemy.position.x = -200 if i == 0 else 200

	enemies = Enemies.get_children()
	Box.setenemies(enemies)
	for i in enemies.size():
		if enemies.size() > 1:
			enemies[i].solo = false
		if enemies[i].kr:
			kr = true
			HUD.set_kr()
		enemies[i].id = i
		enemies[i].changed_state.connect(Box.settargets)
		enemieshp.append(enemies[i].stats.get("hp", 0))
		enemiesmaxhp.append(enemies[i].stats.get("max_hp", 1))
		Box.Blittertext.flavour_texts.append_array(enemies[i].flavour_text if enemies[i].flavour_text else " * %s approaches!" % enemies[i])
		# REWARDS (add more if needed)
		var rwrds = enemies[i].rewards if enemies[i].rewards else {}
		rewards["gold"] += rwrds.get("gold", 0)
		rewards["exp"] += rwrds.get("exp", 0)
		# END
		music = encounter.music
		
		item_used.connect(enemies[i].on_item_used)
		spare_used.connect(enemies[i].on_mercy_used)
		
		enemies[i].spared.connect(spare_enemy)
		endturn.connect(enemies[i]._on_get_turn)

	Camera.blinder.modulate.a = 1
	Camera.blind(0.5, 0)
	Buttons.enable()
	remove_child(Soul_Battle)
	$music.stream = encounter.music
	$music.play()
	Box.ActionMemory[0] = Box.state.Blittering
	Box.Blittertext.blitter(0)

func _physics_process(delta: float) -> void:
	Attacks.TopLeft.position = Vector2(Box.cornerpositions[0].x + 5, Box.cornerpositions[0].y + 5)
	Attacks.BottomRight.position = Vector2(Box.cornerpositions[1].x -5, Box.cornerpositions[1].y -5)

func _act(target: int, option: int):
	enemies[target].on_act_used(option)
	emit_signal("endturn")

func _mercy(choice: int):
	match choice:
		-1:
			emit_signal("endturn")
		0:
			for i in enemies.size():
				if enemies[i]:
					enemies[i].on_mercy_used()
			if not check_end_encounter():
				emit_signal("endturn")
		1:
			await Camera.blind(1, 1)
			Global.temp_atk = 0
			Global.temp_def = 0
			OverworldSceneChanger.load_cached_overworld_scene()

func _item(item_id):
	for e in enemies:
		e.on_item_used(item_id)
	emit_signal("endturn")

# region fight_logic
##Creates the attack meter and handles damaging enemies and showing damage with hit() and miss().
func _fight(target: int):
	var clone = attack.instantiate()
	clone.target = target
	clone.damagetarget.connect(hit)
	clone.missed.connect(miss)
	add_child(clone, true)
	move_child(clone, 1)
	clone.targetdef = enemies[target].stats.get("def", 0)
	await damage_info_finished
	clone.remove_meter()

## Used when the bar doesn't miss (NOT FOR BLOCKING).
func hit(damage, target: int, crit):
	var slashes = slash.instantiate()
	slashes.crit = crit
	Box.add_child(slashes, true)
	slashes.global_position = enemies[target].sprites.global_position
	if enemies[target].dodging:
		enemies[target].dodge()
	await slashes.finished
	damage = floor(damage * slashes.dmg_mult)

	var clone = damageinfo.instantiate()
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
	await enemies[target].on_fight_used()
	if enemieshp[target] < 0.0:
		enemies[target].on_death()
		kill_enemy(target)
	else:
		emit_signal("endturn")

## Used when you miss (for dodging as well).
func miss(target: int):
	var clone = damageinfo.instantiate()
	clone.global_position = enemies[target].sprites.global_position
	clone.hp = enemieshp[target]
	clone.max_hp = enemiesmaxhp[target]
	clone.miss = true
	Box.add_child(clone)
	clone.finished.connect(emit_signal.bind("damage_info_finished"))
	await clone.finished
	emit_signal("endturn")
# endregion

## Kills enemy and checks if the encounter can end.
func kill_enemy(enemy_id: int = 0):
	enemies[enemy_id].on_defeat()
	enemies[enemy_id].script = null
	enemies[enemy_id] = null
	enemynames[enemy_id] = null
	Box.setenemies(enemies)
	if check_end_encounter():
		end_encounter()
	else:
		var _solo = check_enemy_solo()
		for i in enemies.size():
			enemies[i].solo = _solo


func check_enemy_solo() -> bool:
	var enemy_count = 0
	for i in enemies.size():
		if enemies[i]:
			enemy_count += 1
	return enemy_count == 1



func check_end_encounter() -> bool:
	var empty = true
	for i in enemies.size():
		if enemies[i -1] or enemies[i]:
			empty = false
	return empty

## Spares enemy and checks if the encounter can end.
func spare_enemy(enemy_id: int = 0):
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
		var _solo = check_enemy_solo()
		for i in enemies.size():
			if enemies[i]:
				enemies[i].solo = _solo

## Ends encounter and gives rewards.
func end_encounter():
	$music.stop()
	# REWARDS again (add here too)
	Global.player_gold += rewards["gold"]
	Global.player_exp += rewards["exp"]
	var wintxt = Box.wintext
	wintxt = wintxt % [rewards["exp"], rewards["gold"]]
	if Global.check_level_up():
		wintxt += " \n* Your LV increased!"
		$lvlup.play()
	await get_tree().process_frame
	Box.Blitter.show()
	Box.ActionMemory = [Box.state.Blittering]
	Box.Blittertext.typetext(wintxt)
	await Box.Blittertext.finishedalltexts
	await Camera.blind(1, 1)
	Global.temp_atk = 0
	Global.temp_def = 0
	OverworldSceneChanger.load_cached_overworld_scene()

