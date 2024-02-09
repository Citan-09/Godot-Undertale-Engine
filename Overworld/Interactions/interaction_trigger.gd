extends Area2D
class_name InteractionTrigger

signal interacted()

func enable() -> void:
	monitorable = true
	monitoring = true

func disable() -> void:
	monitorable = false
	monitoring = false
