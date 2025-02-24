extends Area2D



func _on_area_entered(area: Area2D) -> void:
	area.get_parent().basicrightclick = false
	get_parent().get_node("trainingdummy").visible = true
	get_parent().get_node("ChargeMouse").visible = true
	queue_free()
