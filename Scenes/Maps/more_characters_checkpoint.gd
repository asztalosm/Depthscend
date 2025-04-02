extends Area2D


func _on_area_entered(area: Area2D) -> void:
	get_parent().get_parent().get_parent().get_node("Characters").giveaccesstochar3 = true
	get_parent().get_node("FloatingEnemies").visible = true
	area.get_parent().get_node("Kb_3").visible = true
	$CollisionShape2D.set_deferred("disabled", true)
	await get_tree().create_timer(1.5).timeout
	area.get_parent().get_parent().giveaccesstochar1 = false
	area.get_parent().get_node("Kb_3").queue_free()
	queue_free()
