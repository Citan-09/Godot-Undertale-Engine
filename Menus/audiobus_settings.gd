extends Control

@export var audio_bus_name := &"Master"


@onready var Name: RichTextLabel = $Margin/Name
@onready var Info: RichTextLabel = $Margin/Info
@onready var VolumeSlider: VSlider = $Margin/VSlider


@onready var audiobus_id: int = AudioServer.get_bus_index(audio_bus_name)

func _ready() -> void:
	Name.text = "[center]" + String(audio_bus_name)
	VolumeSlider.value = Global.settings.get(String(audio_bus_name), 100)
	


func _on_volume_slider_value_changed(value: float) -> void:
	Info.position = Vector2(VolumeSlider.position.x + VolumeSlider.size.x / 2 + 20, get_local_mouse_position().y - 18)
	AudioServer.set_bus_volume_db(audiobus_id, linear_to_db(value / 100.0))
	Info.text = "%3.0f db" % [linear_to_db(value / 100.0)]
	Global.settings[String(audio_bus_name)] = value



func _on_v_slider_drag_started() -> void:
	Info.show()


func _on_v_slider_drag_ended(value_changed: bool) -> void:
	Info.hide()


func _on_bypass_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_bypass_effects(audiobus_id, toggled_on)


func _on_mute_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(audiobus_id, toggled_on)


func _on_solo_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_solo(audiobus_id, toggled_on)
