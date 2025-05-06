extends TextureButton


func _on_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Maps/tutorial_2.tscn")
