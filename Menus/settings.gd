extends Control

var enabled = true
var speed = 20
var hardcodedpositions = [
	Vector2(43, 60),
	Vector2(43, 89),
	Vector2(43, 118),
	Vector2(43, 204)
]
var maxsizey = hardcodedpositions.size()
var souly = 0

var bool_text = {
	"Disabled": false,
	"Enabled": true
}
@onready var soul = $MarginContainer/Soul
@onready var defaultsize = $MarginContainer.size
@onready var defaultpos = position
@export var time = 1.0

func parse_setting_to_text(setting_value):
	if typeof(setting_value) == TYPE_BOOL:
		return bool_text.find_key(setting_value)


func settings_text():
	var settingarray: Array = Global.settings.values()
	settingarray[3] = parse_setting_to_text(settingarray[3])
	var text = "Volume Settings[ul bullet=*]\nMUSIC: {gset} %\nSFX: {gset} %\nMISC: {gset} %[/ul]\n\nVideo Settings\n[ul bullet=*]VFX: {gset}".format(settingarray, "{gset}")
	$MarginContainer/NinePatchRect/MarginContainer/RichTextLabel.text = text

func _input(event: InputEvent) -> void:
	if enabled:
		if event.is_action_pressed("ui_down"):
			if souly < maxsizey -1:
				$choice.play()
				souly += 1
		if event.is_action_pressed("ui_up"):
			if souly > 0:
				$choice.play()
				souly -= 1
		var currentsetting = Global.settings.keys()[souly]
		if event.is_action_pressed("ui_left"):
			$select.play()
			if typeof(Global.settings[currentsetting]) == TYPE_BOOL:
				Global.settings[currentsetting] = !Global.settings[currentsetting]
			elif Global.settings[currentsetting] > 0:
				Global.settings[currentsetting] -= 5.0
			settings_text()
		if event.is_action_pressed("ui_right"):
			$select.play()
			if typeof(Global.settings[currentsetting]) == TYPE_BOOL:
				Global.settings[currentsetting] = !Global.settings[currentsetting]
			elif Global.settings[currentsetting] < 100:
				Global.settings[currentsetting] += 5.0
			settings_text()
		if event.is_action_pressed("ui_accept"):
			$select.play()
			if typeof(Global.settings[currentsetting]) == TYPE_BOOL:
				Global.settings[currentsetting] = !Global.settings[currentsetting]
			settings_text()
		get_viewport().set_input_as_handled()
	if event.is_action_pressed("ui_close") and enabled:
		get_tree().paused = false
		Global.paused = false
		disable()
		return
	if event.is_action_pressed("ui_close") and !enabled:
		get_tree().paused = true
		Global.paused = true
		enable()
		return
	Global.refresh_audio_busses()

func disable():
	enabled = false
	var tw = create_tween().set_parallel().set_trans(Tween.TRANS_EXPO)
	tw.tween_property(self, "position", defaultpos + Vector2(-350, 0), time)
	tw.tween_property($MarginContainer, "size:y", 0, time)
	tw.tween_property(self, "modulate:a", 0, time)
	tw.tween_property($Blur.material, "shader_parameter/lod", 0.0, time / 2.0)

func enable():
	enabled = true
	var tw = create_tween().set_parallel().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "position", defaultpos, time)
	tw.tween_property($MarginContainer, "size:y", defaultsize.y, time)
	tw.tween_property(self, "modulate:a", 1, time)
	tw.tween_property($Blur.material, "shader_parameter/lod", 1.4, time / 2.0)

func _ready() -> void:
	enabled = false
	position = defaultpos + Vector2(-350, 0)
	$MarginContainer.size.y = 0
	modulate.a = 0
	call_deferred("settings_text")
func _process(delta: float) -> void:
	soul.position = soul.position.lerp(hardcodedpositions[souly], delta * speed)
