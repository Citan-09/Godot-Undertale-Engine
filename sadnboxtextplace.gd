extends Node2D

var t = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$bone.setwave(50,"sine",5,20)
	var te = ""
	for i in 100:
		te += str(Extra.sine(i/100.0,1,1))+"\n"
	$Label.text = te

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$ColorRect.size.y = 20+Extra.sine(t,1,20,69)
	$ColorRect2.size.y = 20+Extra.triangle(t,1,20,20)
	
	t+= delta
	

