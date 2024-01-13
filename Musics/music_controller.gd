extends CanvasLayer

var movetween: Tween
var tweentime: float = 0.6

@onready var NamePanel = $Name
@onready var defsize: Vector2 = NamePanel.size
@onready var defpos: Vector2 = NamePanel.position

var musics_o: Dictionary = {
	"default": [^"Overworld/DEFAULT", "[center]DEFAULT OVERWORLD[b]info1\ninfo2\ninfo3"],
}
var misc: Dictionary = {
	"save": [^"Other/save", "[center]OTHER"]
}

var musics = {
	"overworld": musics_o,
	"other": misc,
}

func _ready():
	NamePanel.set_deferred("position", defpos + Vector2(-320, 0))

func play_music_direct(Path: NodePath = ^"Battles/DEFAULT"):
	get_node(Path).play()

func stop_music_direct(Path: NodePath = ^"Battles/DEFAULT"):
	hide_name_panel()
	get_node(Path).stop()

func play_music_key(type: String, key: String, show_info: bool = false):
	if show_info: temp_name_panel(musics.get(type, {}).get(key, [^"Battles/DEFAULT", "[center]DEFAULT\n[b]info1\ninfo2"])[1])
	get_node(musics.get(type, {}).get(key, [^"Battles/DEFAULT", "[center]DEFAULT\n[b]info1\ninfo2"])[0]).play()

func stop_music_key(type: String, key: String):
	hide_name_panel()
	get_node(musics.get(type, {}).get(key, [^"Battles/DEFAULT", "[center]DEFAULT\n[b]info1\ninfo2"])[0]).stop()

func temp_name_panel(Info: String = "[center]DEFAULT\n[b]info1\ninfo2", time: float = 1.2):
	await show_name_panel(Info)
	await get_tree().create_timer(time).timeout
	await hide_name_panel()

func show_name_panel(Info: String = "[center]DEFAULT\n[b]info1\ninfo2"):
	movetween = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT).set_parallel()
	movetween.tween_property(NamePanel, "position", defpos, tweentime)
	movetween.tween_property(NamePanel, "modulate:a", 1, tweentime)
	$Name/MarginContainer/Text.text = Info
	await movetween.finished

func hide_name_panel():
	movetween = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN).set_parallel()
	movetween.tween_property(NamePanel, "position", defpos + Vector2(-320, 0), tweentime)
	movetween.tween_property(NamePanel, "modulate:a", 0, tweentime)
	await movetween.finished
