extends Overworld

func _default_cutscene() -> void:
	await summontextbox().generic(["* WARNING!", "* SANS IS APPROACHING!!!"], ["DIE", "DIE NOW!"], ["* Ok", "* Good desicion!"])
	$YSortNodes/TileMap/Sans.global_position.y = $YSortNodes/TileMap/PlayerOverworld.global_position.y
	$YSortNodes/TileMap/Sans.start_walking(Vector2i.LEFT)

func _default_trigger_battle() -> void:
	await OverworldSceneChanger.load_battle()
	request_ready()
	$YSortNodes/TileMap/Sans.start_walking(Vector2.ZERO)
	$YSortNodes/TileMap/Sans.position.x += 100


func _ready() -> void:
	if Global.flags.get("SANS_FOUGHT", false):
		$YSortNodes/TileMap/CutsceneStarters/Start.disable()
		$YSortNodes/TileMap/CutsceneStarters/SansStop.disable()
