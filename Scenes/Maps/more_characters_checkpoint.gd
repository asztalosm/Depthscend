extends Area2D


func _on_area_entered(area: Area2D) -> void:
	get_parent().get_parent().get_parent().get_node("Characters").giveaccesstomultiplecharacters = true
