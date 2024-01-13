extends PlayerSoul


func showlabel():
	var tw = get_tree().create_tween()
	tw.tween_property($RayCast2D/Label,"modulate:a",1,0.5)
	$RayCast2D/Label.show()

func hidelabel():
	$RayCast2D/Label.hide()

func _extraprocess(delta):
	$RayCast2D.refreshtpsprite(Sprite.texture,Sprite.modulate)

func hurt(damage = 1):
	if canhurt:
		iframes = Game.hurtframe
		canhurt = false
		damage -= Game.def
		damage = max(damage,1)
		if Game.tpcd >= 2.0:
			Game.tpcd -= 2
			modeS.play()
			$Soul/trail2.emitting = true
			Camera.addshake(0.3)
			return
		else:
			hp -= damage
			hurtS.play()
			Camera.addshake(0.4)
		if Game.krbool:
			kr += damage
			if kr > hp -1:
				kr = hp -1
		gui.refresh()
		if hp<=0:
			##DEATH
			canhurt = false
			emit_signal("predeath")
			$Soul/trail.hide()
			$Soul/trail2.hide()
			mode = "nomove"
			Camera.blinder.modulate.a = 1
			self.z_index = 101
			self.velocity = Vector2.ZERO
			var pos = self.position
			for i in 16:
				var tw = get_tree().create_tween()
				tw.tween_property(self,"position",Vector2(pos.x-randf_range(-3-i,3+i),pos.y-randf_range(-3-i,3+i)),0.05)
				Camera.addshake(0.14)
				await tw.finished
			Sprite.texture = load(soul_split)
			if soultype == "monster":
				Sprite.scale.y = -1
			$Crack.play()
			Camera.addshake(0.4)
			Sprite.hide()
			$Explode.play()
			$Shards.restart()
			$Shards.process_material.color = Sprite.modulate
			$Shards.emitting = true
			Camera.addshake(1.3)
			await get_tree().create_timer(1.5).timeout
			get_tree().change_scene_to_file("res://Menu/death_screen.tscn")
			return
