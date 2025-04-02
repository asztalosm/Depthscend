extends Area2D


func _on_area_entered(area: Area2D) -> void:
	if area.get_parent().get_parent().name == "Characters":
		var tween = get_tree().create_tween()
		await tween.tween_property(get_node("TextureRect"), "modulate:a", 0, 0.5).finished
		queue_free()
