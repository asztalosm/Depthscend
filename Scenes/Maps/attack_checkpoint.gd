extends Area2D



func _on_area_entered(area: Area2D) -> void:
	area.get_parent().canmouseattack = true
	get_parent().get_node("trainingdummy").get_node("TextureRect").visible = true
	area.get_parent().get_node("AttackProgress").visible = true
	get_parent().get_parent().get_node("Room1/DoorButton/Arrow2").visible = false
