extends Control

@onready var Camera = $vfx/Camera2D
@onready var plz = $plz
@onready var play = $Play
var current
var line = 0
var col = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	$ColorRect.position.y += 900
	$Gui.play.connect(_on_play_pressed)
	$Gui.quit.connect(_on_quit_pressed)
	if Game.startedgame:
		$ColorRect.modulate.a = 0
		$Gui.disabled = false
		$Music.play()
	pass # Replace with function body.
func _input(event):
	if event.is_action("Confirm") && $ColorRect.modulate.a ==1:
		fadein()
func fadein():
	Game.startedgame = true
	var t = get_tree().create_tween().set_trans(Tween.TRANS_QUAD)
	t.tween_property($ColorRect,"modulate:a",0,1)
	await t.finished
	$Gui.disabled = false
	$Music.play()
		

func _on_play_pressed():
	Data.init()
	play.play()
	await get_tree().create_timer(0.6).timeout
	if !Data.unlockedfights["sans"]:
		get_tree().change_scene_to_file("res://Shared/overworld/overworld.tscn")
	else:
		get_tree().change_scene_to_file("res://Shared/overworld/snowdin.tscn")
	


func _on_quit_pressed():
	play.play()
	await get_tree().create_timer(1).timeout
	$AnimationPlayer.play("boom")
	await get_tree().create_timer(0.15).timeout
	get_tree().quit()

func _process(delta: float) -> void:
	$misc.position = Camera.get_screen_center_position() - Vector2(320,240)

func _on_r_pressed():
	$Gui.disabled = true
	$vfx.position.x = 640


func _on_l_pressed():
	$Gui.disabled = false
	$vfx.position.x = 0
