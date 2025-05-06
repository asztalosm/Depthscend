extends Area2D
var mousehintclicked = false

func _on_area_entered(area: Area2D) -> void:
	var door = self.get_parent().get_node("Door")
	door.queue_free()
	set_deferred("monitoring", false)
	$ColorRect.color = Color(255,0,0)
	$Mouselclick.queue_free()
	$PointLight2D.queue_free()
	$MouseHint.queue_free()
	$TextureRect/GPUParticles2D.queue_free()
	area.get_parent().get_node("Keys").visible = true
	area.get_parent().canwasdmove = true
	area.get_parent().canmousemove = false

func _on_mouse_hint_timeout() -> void:
	if !mousehintclicked:
		$Mouselclick.texture = load("res://Textures/mouselclick.png")
		mousehintclicked = true
	else:
		$Mouselclick.texture = load("res://Textures/mousetemplate.png")
		mousehintclicked = false
