extends Control

var option = 4 #0 back 1: Fullscreen 2:Volume 3:VFX #

var insettings = false
var disabled = true
var speed = 30.0

signal play
signal quit
func _unhandled_input(event):
	if insettings && !disabled:
		if event.is_action_pressed("ui_down") && option < 3:
			option += 1
			$Squeak.play()
		if event.is_action_pressed("ui_up") && option > 0:
			option -= 1
			$Squeak.play()
		if event.is_action_pressed("Confirm"):
			match option:
				0:
					option = 5
					insettings = false
					$Select.play()
				1:
					Global.togglefull()
				3:
					if Data.settings["vfxmult"]:
						Data.settings["vfxmult"] =false
					else:
						Data.settings["vfxmult"] =true
		if event.is_action("ui_left"):
			$Squeak.play()
			match option:
				2:
					Data.settings["volume"] -= 2
					if Data.settings["volume"] < 0:
						Data.settings["volume"] = 0
				3:
					Data.settings["vfxmult"] = false
		if event.is_action("ui_right"):
			$Squeak.play()
			match option:
				2:
					Data.settings["volume"] += 2
					if Data.settings["volume"] > 100:
						Data.settings["volume"] = 100
				3:
					Data.settings["vfxmult"] = true
	elif !disabled:
		if event.is_action_pressed("ui_down") && option < 6:
			option += 1
			$Squeak.play()
		if event.is_action_pressed("ui_up") && option > 4:
			option -= 1
			$Squeak.play()
		if event.is_action_pressed("Confirm"):
			match option:
				4:
					emit_signal("play")
					disabled = true
				5:
					option = 0
					insettings = true
					$Select.play()
				6:
					emit_signal("quit")
					disabled = true
			
	update()
	
# Called when the node enters the scene tree for the first time.
func _ready():
	update()
func update():
	get_node("/root/menu/vfx").visible = Data.settings["vfxmult"]
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),linear_to_db(Data.settings["volume"]/100.0))
	$Settings/ast/RichTextLabel.text = "Back \nFullscreen: "+str(Global.fullsc)+"\nVolume: "+str(Data.settings["volume"])+"%\nVisual Effects: "+ str(Data.settings["vfxmult"])+"\n[b](this includes flashing lights and shit so be careful :D)"

@export var movespeed = 6
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !insettings:
		$Sprite2D.position = $Sprite2D.position.lerp(Vector2($ast2.position.x+7,$ast2.position.y+16 + 28*(option-4)),delta*speed)
		$Settings.position = $Settings.position.lerp(Vector2(-640,0),delta*movespeed)
	else:
		$Sprite2D.position = $Sprite2D.position.lerp(Vector2($Settings/ast.position.x+7+$Settings.position.x,$Settings/ast.position.y+16 + 28*option),delta*speed)
		$Settings.position = $Settings.position.lerp(Vector2(0,0),delta*movespeed)
