extends CheckButton

@export var setting_name := ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button_pressed = Global.settings.get(setting_name)
	toggled.connect(_on_toggled)


func _on_toggled(val: bool) -> void:
	if !Global.settings.get(setting_name) is bool:
		push_error("Setting is NOT boolean.")
		return
	Global.settings[setting_name] = val

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
