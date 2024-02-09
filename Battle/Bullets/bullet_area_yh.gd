class_name BulletAreaYellowHittable extends BulletArea


func _on_yellow_bullet_hit() -> void:
	assert(parent.has_method("_on_hit_yellow"), "Bullet is missing \"_on_hit_yellow\" method.") # Don't remove unless u wanna change this method.
	parent._on_hit_yellow() # Override/change if u want
