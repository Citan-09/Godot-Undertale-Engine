class_name SettingBoolButton extends CheckButton

@export var setting_name := ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	toggled.connect(_on_toggled)
	button_pressed = Global.settings.get(setting_name, false)



func _on_toggled(val: bool) -> void:
	if !Global.settings.get(setting_name) is bool:
		if !Global.settings.get(setting_name):
			push_error("Setting is NULL, please set it in Global singleton.")
			return
		push_error("Setting is NOT boolean.")
		return
	Global.settings[setting_name] = val
