extends Area2D

var tag = ""
var velocity:Vector2 = Vector2.ZERO
var mode = 0
func _ready() -> void:
	self.modulate.a = 0
func _physics_process(delta: float) -> void:
	self.position += velocity * delta

func fire(targetposition:Vector2,delay=0.2,speed=100):
	var tw = get_tree().create_tween()
	tw.tween_property(self,"modulate:a",1,min(delay,0.2))
	$Summon.play()
	self.rotation_degrees = Extra.returnrotationdeg(self.position,targetposition) - 180
	await get_tree().create_timer(max(0.2,delay),false).timeout
	tw = get_tree().create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tw.tween_property(self,"velocity",(targetposition - global_position).normalized() * speed,0.5)
	await get_tree().create_timer(0.25).timeout
	$Throw.play()
	
	
	
	
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
