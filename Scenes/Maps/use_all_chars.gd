extends Area2D

func _on_area_entered(area: Area2D) -> void:
	if area.get_parent().get_parent().name == "Characters":
		area.get_parent().get_parent().giveaccesstochar1 = true
		area.get_parent().get_parent().giveaccesstochar2 = true
		area.get_parent().get_parent().giveaccesstochar3 = true
		queue_free()
