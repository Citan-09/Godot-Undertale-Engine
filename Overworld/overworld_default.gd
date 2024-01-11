extends Overworld

func _default_cutscene():
	await summontextbox().generic(["* WARNING!","* SANS IS APPROACHING!!!"],["DIE","DIE NOW!"],["* Ok","* Good desicion!"])
	$YSortNodes/TileMap/Sans.global_position.y = $YSortNodes/TileMap/PlayerOverworld.global_position.y
	$YSortNodes/TileMap/Sans.start_walking(Vector2i.LEFT)

func _default_trigger_battle():
	Global.flags["done_sans"] = true
	await load_battle_save_data()

func _ready():
	if Global.flags["done_sans"]:
		$YSortNodes/TileMap/CutsceneStarters/Start.queue_free()
		$YSortNodes/TileMap/CutsceneStarters/SansStop.queue_free()
