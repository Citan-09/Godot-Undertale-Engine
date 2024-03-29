class_name Slash extends AnimatedSprite2D

@onready var AnimTree: AnimationTree = $AnimationTree
@onready var animtree: AnimationNodeStateMachinePlayback = AnimTree.get("parameters/playback")


signal finished
signal started
signal punchfinish
var canpunch := false
var z_count: int = 0
var crit: bool
var dmg_mult: float = 1.0


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and canpunch:
		$GPUParticles2D3.process_material.scale_max += 0.1
		$GPUParticles2D3.process_material.scale_min += 0.1
		$GPUParticles2D3.amount_ratio += 1.0 / 5.0
		z_count += 1
		$PunchW.play()
		if z_count > 2:
			emit_signal("punchfinish")
		if animtree.get_current_node() != "punch" or animtree.get_current_node() != "explosion":
			animtree.start("punch")
func _ready() -> void:
	$GPUParticles2D3.process_material.scale_max = 0.2
	$GPUParticles2D3.process_material.scale_min = 0.4
	var tw := create_tween()
	tw.stop()
	if crit:
		modulate = Color("fffd8a")
	match Global.item_list[Global.equipment["weapon"]].weapon_type:
		Global.weaponstype.KNIFE:
			started.emit()
			animtree.start("slash")
			tw.tween_callback(emit_signal.bind("finished")).set_delay(0.6)
		Global.weaponstype.PUNCH:
			$GPUParticles2D3.emitting = true
			canpunch = true
			$press_z.show()
			get_tree().create_timer(0.8).timeout.connect(emit_signal.bind("punchfinish"))
			await punchfinish
			started.emit()
			tw.tween_callback(emit_signal.bind("finished")).set_delay(0.5)
			canpunch = false
			animtree.next()
			if z_count > 2:
				$AnimationTree.set("parameters/conditions/pressed_z_times", true)
			else:
				dmg_mult = min(z_count / 4.0 + 0.25, 1.0)
				animtree.start("punch")
				$AnimationTree.set("parameters/conditions/weak", true)
		Global.weaponstype.SHOE:
			started.emit()
			tw.tween_callback(emit_signal.bind("finished")).set_delay(0.4)
			animtree.start("shoe")
			if crit:
				$Sparkle.play()
		Global.weaponstype.BOOK:
			started.emit()
			tw.tween_callback(emit_signal.bind("finished")).set_delay(0.7)
			animtree.start("book")
			if crit:
				$Sparkle.play()
		Global.weaponstype.PAN:
			started.emit()
			tw.tween_callback(emit_signal.bind("finished")).set_delay(0.5)
			animtree.start("pan")
			if crit:
				$Sparkle.play()
		Global.weaponstype.GUN:
			started.emit()
			tw.tween_callback(emit_signal.bind("finished")).set_delay(0.6)
			animtree.start("gun")
			if crit:
				$Sparkle.play()
	tw.play()
	while animtree.get_current_node() != "End":
		await AnimTree.animation_finished
	hide()
	if !tw.is_valid(): finished.emit()
	queue_free()
