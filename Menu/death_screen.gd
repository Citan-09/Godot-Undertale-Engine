extends Control

var speed = 20.0
@onready var soul:Sprite2D = $MenuPointer/Soul
var soulpos = 0
var pos = [Vector2(0,0),Vector2(145,0)]
var encounter = "sans"
var disabled= false

func _ready():
	var tw = get_tree().create_tween()
	tw.tween_property($Music,"volume_db",0,0.6)
	$Camera2D.blinder.modulate.a = 1
	$Camera2D.unblind(0.8)
	$Music.play()
	encounter = Game.mname.to_lower()

func _process(delta):
	soul.position = soul.position.lerp(pos[soulpos],delta*speed)

func _input(event):
	if disabled:
		return
	if event.is_action_pressed("ui_left") && soulpos >0:
		soulpos-=1
		$MenuPointer/Squeak.play()
	if event.is_action_pressed("ui_right") && soulpos <1:
		soulpos+=1
		$MenuPointer/Squeak.play()
	if event.is_action_pressed("Confirm"):
		disabled = true
		$Camera2D.blind(0.8)
		var tw = get_tree().create_tween()
		tw.tween_property($Music,"volume_db",-56,1)
		await $Camera2D.faded
		if soulpos ==0:
			$IntoFight.directbattle(encounter)
		if soulpos>0:
			get_tree().change_scene_to_file("res://Menu/menu.tscn")
