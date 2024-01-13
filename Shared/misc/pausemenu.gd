extends CanvasLayer

var canpause = false
signal faded

@onready var spritey = $Control/Sprites.position.y
func _ready() -> void:
	$Control/Sprites.position.y += 480
	$Control/NinePatchRect.size.x = 20
	$Control/NinePatchRect2.size.x = 20
	$Control.modulate.a = 0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_leave"):
		if !get_tree().paused:
			get_tree().paused = true
			Global.paused = true
			fadein()
			canpause = true
		elif canpause:
			canpause = false
			fadeout()
			get_tree().paused = false
			Global.paused = false
			
		
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("slow_down")&&canpause&&Global.paused:
		var tw = create_tween().set_trans(Tween.TRANS_CIRC)
		canpause = false
		set_process(false)
		tw.tween_property($Control/Overlay,"modulate:a",1,0.5)
		await tw.finished
		Global.paused = false
		Global.unpausein(0.1)
		get_tree().change_scene_to_file("res://Menu/menu.tscn")
		
		

func fadein():
	var tw = create_tween().set_trans(Tween.TRANS_CIRC)
	tw.set_parallel(true)
	tw.tween_property($Control,"modulate:a",1,0.5)
	tw.tween_property($blur.material,"shader_parameter/lod",0.5,0.4)
	tw.tween_property($Control/NinePatchRect,"size:x",181,0.4)
	tw.tween_property($Control/NinePatchRect2,"size:x",617,0.4)
	tw.tween_property($Control/Sprites,"position:y",spritey,0.3)
	tw.tween_callback(emit_signal.bind("faded")).set_delay(0.2)
	
func fadeout():
	var tw = create_tween().set_trans(Tween.TRANS_CIRC)
	tw.set_parallel(true)
	tw.tween_property($Control/NinePatchRect,"size:x",20,0.4)
	tw.tween_property($blur.material,"shader_parameter/lod",0,0.4)
	tw.tween_property($Control,"modulate:a",0,0.5)
	tw.tween_property($Control/Sprites,"position:y",spritey+480,0.3)
	tw.tween_property($Control/NinePatchRect2,"size:x",20,0.4)
	tw.tween_callback(emit_signal.bind("faded")).set_delay(0.2)
	
	
