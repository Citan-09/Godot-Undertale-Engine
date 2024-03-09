extends Control

@export var audio_bus_name := &"Master"


@onready var Name: RichTextLabel = $Margin/Name
@onready var Info: RichTextLabel = $Margin/Info
@onready var VolumeSlider: VSlider = $Margin/VSlider


@onready var audiobus_id: int = AudioServer.get_bus_index(audio_bus_name)

func _ready() -> void:
	Name.text = "[center]" + String(audio_bus_name)
	VolumeSlider.set_value_no_signal(Global.settings.get(String(audio_bus_name), 100))
	
var tw: Tween

func _on_volume_slider_value_changed(value: float) -> void:
	Info.position = Vector2(
		VolumeSlider.position.x + VolumeSlider.size.x / 2 + 20,
		lerpf(1 - VolumeSlider.value / VolumeSlider.max_value, 0.5, 0.3) * VolumeSlider.size.y - 10 + VolumeSlider.position.y)
	AudioServer.set_bus_volume_db(audiobus_id, linear_to_db(value / 100.0))
	Info.text = "%3.0f db" % [linear_to_db(value / 100.0)]
	Global.settings[String(audio_bus_name)] = value
	_on_v_slider_drag_started()
	if tw and tw.is_valid():
		tw.kill()
	tw = create_tween()
	tw.tween_callback(_on_v_slider_drag_ended).set_delay(0.5)
	



func _on_v_slider_drag_started() -> void:
	Info.show()


func _on_v_slider_drag_ended() -> void:
	Info.hide()


func _on_bypass_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_bypass_effects(audiobus_id, toggled_on)


func _on_mute_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(audiobus_id, toggled_on)


func _on_solo_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_solo(audiobus_id, toggled_on)

