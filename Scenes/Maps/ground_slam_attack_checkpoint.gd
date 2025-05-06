extends Area2D


func _on_area_entered(_area: Area2D) -> void:
	get_parent().get_node("trainingdummy").visible = true
	get_parent().get_node("Chest").visible = true
	queue_free()
