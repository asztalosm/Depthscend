extends TextureButton


func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Maps/tutorial_2.tscn") # átváltja a jelenetet tutorial2-re gomb megnyomásakor, kitörli a menu.tscn által foglalt memóriát 
