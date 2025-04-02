extends CanvasLayer
@onready var hoverstats = $HoverStats
@onready var pausemenu = $PauseMenu
@onready var charmholder = $HoverStats/Charmholder
func _on_current_character_mouse_entered() -> void:
	hoverstats.visible = true
	if get_parent().exportchars != []:
		var currentchar = get_parent().exportchars[get_parent().globalcurrentchar]
		var counter = 0
		for elements in currentchar.guistats:  #betöltésenként a statokat és a charmokat betölti a hoverstats nodeba
			var stattemplatecopy = $HoverStats/StatTemplate.duplicate()
			$HoverStats/GridContainer.add_child(stattemplatecopy)
			stattemplatecopy.visible = true
			stattemplatecopy.get_node("TextureRect").texture = currentchar.guistats[counter][0]
			stattemplatecopy.get_node("Label").text = str(currentchar.guistats[counter][1])
			counter += 1
		for charm in currentchar.charms:
			if charm[1] == true:
				charmholder.texture = charm[2]

func _on_current_character_mouse_exited() -> void:
	for children in $HoverStats/GridContainer.get_children():
		children.queue_free()
	hoverstats.visible = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		if pausemenu.visible == true:
			pausemenu.visible = false
			get_tree().paused = false
		else: 
			pausemenu.visible = true
			get_tree().paused = true


func _on_resume_button_pressed() -> void:
	pausemenu.visible = false
	get_tree().paused = false


func _on_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Maps/menu.tscn")
