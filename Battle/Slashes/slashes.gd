extends AnimatedSprite2D

@onready var animtree: AnimationNodeStateMachinePlayback = $AnimationTree.get("parameters/playback")

signal finished
signal punchfinish
var canpunch := false
var z_count = 0
var crit
var dmg_mult = 1.0

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
	if crit:
		modulate = Color("fffd8a")
	match Global.item_list[Global.equipment["weapon"]].weapon_type:
		Global.weaponstype.KNIFE:
			animtree.start("slash")
		Global.weaponstype.PUNCH:
			$GPUParticles2D3.emitting = true
			canpunch = true
			$press_z.show()
			get_tree().create_timer(0.8).timeout.connect(emit_signal.bind("punchfinish"))
			await punchfinish
			canpunch = false
			animtree.next()
			if z_count > 2:
				$AnimationTree.set("parameters/conditions/pressed_z_times", true)
			else:
				dmg_mult = min(z_count / 4.0 + 0.25, 1.0)
				animtree.start("punch")
				$AnimationTree.set("parameters/conditions/weak", true)
		Global.weaponstype.SHOE:
			animtree.start("shoe")
			if crit:
				$Sparkle.play()
		Global.weaponstype.BOOK:
			animtree.start("book")
			if crit:
				$Sparkle.play()
		Global.weaponstype.PAN:
			animtree.start("pan")
			if crit:
				$Sparkle.play()
		Global.weaponstype.GUN:
			animtree.start("gun")
			if crit:
				$Sparkle.play()
	while animtree.get_current_node() != "End":
		if get_tree():
			await get_tree().process_frame
		else:
			break
	hide()
	emit_signal("finished")
	hide()
	$Timer.start()
	await $Timer.timeout
	queue_free()
