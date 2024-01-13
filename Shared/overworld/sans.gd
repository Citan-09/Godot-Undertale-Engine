extends AnimatableBody2D

signal done
@export var speed = 50.0
var counter = 1
var canmove = false


func _process(delta):
	if canmove:
		self.position.y += speed * delta

func _on_timer() -> void:
	if canmove:
		if counter % 2 ==1:
			$step.play()
		$Sprite.frame = counter % 4
		counter += 1
	elif $Sprite.frame % 2 == 1:
		$Sprite.frame = 0
