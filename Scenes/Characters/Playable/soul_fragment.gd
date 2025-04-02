extends Area2D

func _on_area_entered(area: Area2D) -> void:
	if area.get_parent().get_parent().name.to_lower() == "characters":
		if area.get_parent().health < area.get_parent().maxhealth:
			area.get_parent().health += 1
			var charactereffect = preload("res://Shaders/characterstatuseffects.tscn").instantiate()
			area.get_parent().add_child(charactereffect)
			charactereffect.texture = preload("res://Particles/Heal.png")
			charactereffect.global_position = area.get_parent().global_position
			charactereffect.emitting = true
			area.get_parent().get_node("effects").play("heal")
		else:
			area.get_parent().health = area.get_parent().maxhealth
	else:
		var charactereffect = preload("res://Shaders/characterstatuseffects.tscn").instantiate()
		area.get_parent().add_child(charactereffect)
		charactereffect.texture = preload("res://Particles/soulteardamage.png")
		charactereffect.global_position = area.get_parent().global_position
		charactereffect.emitting = true
		area.get_parent().health -= 2
	queue_free()
