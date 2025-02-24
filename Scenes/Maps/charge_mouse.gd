extends TextureRect



func _on_timer_timeout() -> void:
	if self.visible:
		self.texture = load("res://Textures/mousechargedstarted.png")
		await get_tree().create_timer(0.8).timeout
		self.texture = load("res://Textures/mousechargedmiddle.png")
		await get_tree().create_timer(0.8).timeout
		self.texture = load("res://Textures/mousechargedfinished.png")
