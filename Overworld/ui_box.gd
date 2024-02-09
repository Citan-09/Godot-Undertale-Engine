extends NinePatchRect

@onready var defsize: Vector2 = size
#
#@export_enum("HORIZONTAL", "VERTICAL") var grow_mode = 0

var tw: Tween

func _ready() -> void:
	modulate.a = 0
	hide()

func grow() -> void:
	show()
	if tw and tw.is_valid(): tw.kill()
	tw = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT).set_parallel()
	tw.tween_property(self, "modulate:a", 1, 0.5)

func shrink() -> void:
	if tw and tw.is_valid(): tw.kill()
	tw = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT).set_parallel()
	tw.tween_property(self, "modulate:a", 0, 0.5)
	tw.chain().tween_callback(hide)
