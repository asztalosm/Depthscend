extends Area2D

func _on_area_entered(area: Area2D) -> void:
	if area.get_parent().get_parent().name.to_lower() == "characters":
		if not area.get_parent().health >= area.get_parent().maxhealth -2:
			area.get_parent().health += 1
			queue_free()
		else:
			area.get_parent().health = area.get_parent().maxhealth
			queue_free()
	else:
		area.get_parent().health -= 2
		queue_free()
