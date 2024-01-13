extends Node

var fullsc = false
var debug = false
var paused = false
var canmove = true

func unpausein(time:float = 0.2) -> void:
	await get_tree().create_timer(time).timeout
	get_tree().paused = false

func togglefull():
	if !fullsc:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		fullsc = true
	elif fullsc:
		fullsc = false
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("toggle_fullscreen"):
		togglefull()
	if Input.is_action_just_pressed("debugenable"):
		debug = true
	
		
