extends NinePatchRect

@onready var defsize: Vector2 = size

@export_enum("HORIZONTAL", "VERTICAL") var grow_mode = 0

var tw: Tween

func _ready():
	if grow_mode:
		size.y = 0
	else:
		size.x = 0
	modulate.a = 0
	hide()

func grow():
	show()
	if tw and tw.is_valid(): tw.kill()
	tw = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT).set_parallel()
	if grow_mode:
		tw.tween_property(self, "size:y", defsize.y, 0.5)
	else:
		tw.tween_property(self, "size:x", defsize.x, 0.5)
	tw.tween_property(self, "modulate:a", 1, 0.5)

func shrink():
	if tw and tw.is_valid(): tw.kill()
	tw = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT).set_parallel()
	if grow_mode:
		tw.tween_property(self, "size:y", 0, 0.5)
	else:
		tw.tween_property(self, "size:x", 0, 0.5)
	tw.tween_property(self, "modulate:a", 0, 0.5)
	tw.chain().tween_callback(hide)
