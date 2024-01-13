extends Node2D
@onready var stage = $Stage/Sprite2D
@onready var topplat = $Stage
@onready var pillar = $Support
@onready var stars = $ParallaxBackground

signal finish
func lightenstage():
	var t = get_tree().create_tween()
	t.tween_property(stage,"modulate:r",0.75,0.5).set_trans(Tween.TRANS_SINE)
	t.tween_property(stage,"modulate:r",1,0.5).set_trans(Tween.TRANS_SINE)
	await t.finished
	lightenstage()
# Called when the node enters the scene tree for the first time.
func _ready():
	stars.hide()
	lightenstage()


signal incby16
signal isdone
var time = 6
func rise(y:float):
	$Appear.play()
	var tween = get_tree().create_tween()
	tween.tween_property(topplat,"position:y",-y,time).set_trans(Tween.TRANS_SINE)
	var m = y/20.0
	$Rise.play()
	var t2 = get_tree().create_tween()
	t2.tween_property($Rise,"volume_db",-16,0.8).set_trans(Tween.TRANS_CUBIC)
	for i in 2:
		addtiles()
	for i in range(2,m):
		addtiles()
		await incby16
	await get_tree().create_timer(1).timeout
	$Rise.stop()
	self.position.y = -y
	tween.stop()
	emit_signal("finish")

@export var left = Vector2.ZERO
@export var right = Vector2.ZERO
@export var middle = Vector2.ZERO
@export var scrollspeed = 100
var h = 0
var currenty = 0
var lasty = 0
func addtiles():
	h +=1
	for i in 4:
		pillar.set_cell(0,Vector2i(-5+i,2-h+i),0,left)
	for i in 2:
		pillar.set_cell(0,Vector2i(-1+i,5-h),0,middle)
	for i in 4:
		pillar.set_cell(0,Vector2i(4-i,2-h+i),0,right)
		
func _process(delta):
	currenty = ceil(abs(topplat.position.y/20.0))
	if currenty > lasty:
		lasty = currenty
		emit_signal("incby16")
	if topplat.position.y < -180&& !stars.visible:
		$Wind3.emitting = true
		stars.show()
		var tween = get_tree().create_tween()
		tween.tween_property($ParallaxBackground/ParallaxLayer/stars,"modulate:a",1,0.5)
	else:
		$Wind3.emitting = false
	stars.scroll_base_offset.y += delta * scrollspeed
