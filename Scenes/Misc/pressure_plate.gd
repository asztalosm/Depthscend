extends Area2D
var triggered = false

func _on_area_entered(area: Area2D) -> void:
	if !triggered:
		if area.get_parent().get_parent().name == "Characters":
			if get_path_to(get_parent().get_node(self.name + "Connection")) != null:
				get_parent().get_node(self.name + "Connection").visible = true
				modulate = Color(1,1,1)
				if is_instance_valid($StaticBody2D):
					$StaticBody2D.queue_free()
			if get_node_or_null("StaticBody2D") != null:
				$StaticBody2D.queue_free()
				modulate = Color(1,1,1)
			triggered = true
	else:
		pass
