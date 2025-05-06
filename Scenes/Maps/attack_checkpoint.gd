extends Area2D



func _on_area_entered(area: Area2D) -> void:
	get_parent().get_node("trainingdummy").visible = true
	area.get_parent().get_node("AttackProgress").visible = true
	area.get_parent().canmouseattack = true
	queue_free()
