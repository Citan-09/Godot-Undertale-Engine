extends TextTyperGeneric

var changingscene = false
@onready var Camera = $Camera2D
signal changedbg

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Confirm")&& !changingscene:
		changingscene = true
		intomenu()

var text = [
	"ONCE UPON A TIME, WAR BROKE OUT BETWEEN HUMANS AND MONSTERS...",
	"THE HUMANS WON, AND THEY BANISHED ALL THE MONSTERS TO THE UNDERGROUND.",
	"ONE DAY,A HUMAN FELL DOWN INTO THE UNDERGROUND...\nAND KILLED THEM ALL.",
	"NO ONE STOOD A CHANCE AGAINST THE POWER OF THEIR [color=yellow]DETERMINATION.",
	"HOWEVER, AS THE GENOCIDES KEPT REPEATING, RESET AFTER RESET...\nDUSTNUSTS.",
	"AND PAPYRUS STARTED KILLING ALL OF HIS FRIENDS...",
	"[shake]WHEN SANS FOUND PAPYRUS IN SNOWDIN FORSET, WALKING LIKE A PSYCHOSIS DUSTTRUST... HE TRIED TO KILL SNAS.",
	"SADLY, PAPYRUS FAILED... AS A DYING WISH, PAPYRUS MADE SANS PROMISE TO BECOME DUSTNUTS.",
	"SANS, DISTRAUGHT, AGREED.",
	"HOWEVER SANS HAD NOT THOUGHT THE PLAN THROUGH, ALMOST DYING BEFORE THE FINAL ENCOUNTER!",
	"BUT IN THE END, HE HAD GOTTEN ENOUGH [color=red]LV[/color]...",
	"---> 308 Negra Arroyo Lane, Albuquerque, New Mexico <---",
	"FINALY, IT WAS TIME TO END THIS ONCE AND FOR ALL!!!!!!!!!"]

func _ready():
	$vfx.visible = Data.settings["vfxmult"]
	Camera.vignette.show()
	Textlabel = $Panels/RichTextLabel
	sound = $Panels/RichTextLabel/Click
	time = 0.2
	finish.connect(fadepanel)
	repeattext(text)
	intro()

var bgnum = 0
func changepanel():
	bgnum +=1
	##CHANGE PANEL
func fadepanel():
	await get_tree().create_timer(0.4).timeout
	var tw = get_tree().create_tween()
	tw.tween_property($Panels,"modulate:a",0,0.5)
	tw.tween_callback(changepanel)
	tw.tween_callback(Textlabel.set_text.bind(""))
	tw.tween_interval(0.1)
	tw.tween_property($Panels,"modulate:a",1,0.5)
	tw.tween_callback(emit_signal.bind("changedbg"))
func intro():
	for i in text.size():
		await finish
		await changedbg
		if text.size()-3 < i:
			await get_tree().create_timer(0.5).timeout 
		if text.size() -2 < i:
			await get_tree().create_timer(4).timeout 
		emit_signal("confirm")
	intomenu()
func intomenu():
	set_process(false)
	cancel = true
	Camera.blind(1)
	var tw = get_tree().create_tween()
	tw.tween_property($music,"volume_db",-50,1)
	await Camera.faded
	get_tree().change_scene_to_file("res://Menu/menu.tscn")
