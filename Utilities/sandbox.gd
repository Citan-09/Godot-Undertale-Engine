extends AttackBase

func _input(event: InputEvent) -> void:
	if event is InputEventMouse and event.is_pressed():
		pass


#var repeats = 100000
#
#var size = 400
#var arr = {}
#var result
#func _ready():
	#for i in size:
		#arr.merge({str(i): randf()})
	#var t1 = Time.get_unix_time_from_system()
	#for i in repeats:
		#result = arr.find_key(randf())
#
	#var t2 = Time.get_unix_time_from_system()
	#print(t2 -t1)
func _ready() -> void:
	$Timer.start()


func _on_timer_timeout() -> void:
	var clone = blaster.instantiate()
	add_child(clone)
	clone.rotation = fmod(Time.get_unix_time_from_system()*5,TAU)
	clone.position = Vector2(320,240) + Vector2.UP.rotated(clone.rotation) * 500.0
	clone.fire(Vector2(320,240) + Vector2.UP.rotated(clone.rotation) * 200.0, 2, 0.2, 0.75, randi_range(0,3))
