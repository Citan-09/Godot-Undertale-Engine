extends Node2D

@onready var papyrusanim = $Papyrus.get_node("AnimationPlayer")
@onready var Cammove = $SansCam
@onready var Camera :Camera2DVFX= $SansCam/Camera2D

# Called when the node enters the scene tree for the first time.
func _ready():
	$Papyrus/Cross.play("default")
	$SansCam/Camera2D.vignette.show()
	$SansCam/Camera2D.blinder.modulate.a = 1
	$SansCam/Camera2D.unblind(0.5)
	$OverworldDBox.holdbattle.connect(papyrussaysweed)
	$Sans.canmove = false
	await get_tree().create_timer(0.5).timeout
	$Sans.canmove = true

func papyrussaysweed():
	await $OverworldDBox.confirm
	$IntoFight.intobattle(Vector2(320,240),"papyrus","monster")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	Cammove.position = $Sans.position
	Camera.IceOverlay.modulate.a = Cammove.position.y/176.0

func _on_area_body_entered(body):
	if body.is_in_group("sans"):
		$Sans.modulate.a = 0
		$Papyrus.modulate.a = 0
		$Sans.z_index = 110
		$alert.play()
		body.canmove = false
		var twm = get_tree().create_tween()
		twm.tween_property($Papyrus,"modulate:a",1,0.7)
		twm.tween_callback(papyrusanim.play.bind("turn"))
		twm.tween_property($Sans,"modulate:a",1,0.6)
		await twm.finished
		$OverworldDBox.summon($Sans.position,"papyrusencounter","snowdin")
	pass # Replace with function body.
