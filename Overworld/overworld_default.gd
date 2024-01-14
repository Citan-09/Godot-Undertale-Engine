extends Overworld

func _default_cutscene():
	await summontextbox().generic(["* WARNING!", "* SANS IS APPROACHING!!!"], ["DIE", "DIE NOW!"], ["* Ok", "* Good desicion!"])
	$YSortNodes/TileMap/Sans.global_position.y = $YSortNodes/TileMap/PlayerOverworld.global_position.y
	$YSortNodes/TileMap/Sans.start_walking(Vector2i.LEFT)

func _default_trigger_battle():
	await Global.load_battle()
	request_ready()
	$YSortNodes/TileMap/Sans.start_walking(Vector2.ZERO)
	$YSortNodes/TileMap/Sans.position.x += 100
	#await load_battle_save_data()

func _ready():
	if Global.flags & Global.Flag.DEFEATED_DEFAULT_ENEMY:
		$YSortNodes/TileMap/CutsceneStarters/Start.disable()
		$YSortNodes/TileMap/CutsceneStarters/SansStop.disable()
