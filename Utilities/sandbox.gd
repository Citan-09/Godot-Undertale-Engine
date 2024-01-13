extends Node2D

var repeats = 100000

var size = 400
var arr = {}
var result
func _ready():
	for i in size:
		arr.merge({str(i): randf()})
	var t1 = Time.get_unix_time_from_system()
	for i in repeats:
		result = arr.find_key(randf())

	var t2 = Time.get_unix_time_from_system()
	print(t2 -t1)

