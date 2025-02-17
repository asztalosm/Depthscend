extends Area2D
var mousehintclicked = false

func _on_area_entered(_area: Area2D) -> void:
	var door = self.get_parent().get_node("StaticBody2D")
	door.queue_free()
	set_deferred("monitoring", false)
	$ColorRect.color = Color(255,0,0)
	$Arrow1.visible = false
	$Arrow2.visible = true
	$Mouselclick.visible = false
	$PointLight2D.queue_free()

func _on_mouse_hint_timeout() -> void:
	if !mousehintclicked:
		$Mouselclick.texture = load("res://Textures/mouselclick.png")
		mousehintclicked = true
	else:
		$Mouselclick.texture = load("res://Textures/mousetemplate.png")
		mousehintclicked = false
