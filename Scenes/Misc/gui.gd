extends CanvasLayer
@onready var hoverstats = $HoverStats
func _on_current_character_mouse_entered(path) -> void:
	hoverstats.visible = true
	if get_parent().exportchars != []:
		var currentchar = get_parent().exportchars[get_parent().globalcurrentchar]
		var counter = 0
		for elements in currentchar.guistats:
			var stattemplatecopy = $HoverStats/StatTemplate.duplicate()
			$HoverStats/GridContainer.add_child(stattemplatecopy)
			stattemplatecopy.visible = true
			stattemplatecopy.get_node("TextureRect").texture = currentchar.guistats[counter][0]
			stattemplatecopy.get_node("Label").text = str(currentchar.guistats[counter][1])
			counter += 1

func _on_current_character_mouse_exited() -> void:
	for children in $HoverStats/GridContainer.get_children():
		children.queue_free()
	hoverstats.visible = false
