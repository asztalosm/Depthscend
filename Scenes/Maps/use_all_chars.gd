extends Area2D

func _on_area_entered(area: Area2D) -> void:
	if area.get_parent().get_parent().name == "Characters":
		area.get_parent().get_parent().get_node("character2").charms[0][1] = true
		area.get_parent().get_parent().giveaccesstochar1 = true
		area.get_parent().get_parent().giveaccesstochar2 = true
		area.get_parent().get_parent().giveaccesstochar3 = true
		var newtexturerect = TextureRect.new()
		newtexturerect.texture = load("res://Textures/Dash.png")
		newtexturerect.custom_minimum_size = Vector2(64,64)
		get_parent().get_parent().get_parent().get_node("Characters/GUI/Charms/GridContainer").add_child(newtexturerect)
		
		queue_free()
