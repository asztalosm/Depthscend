extends TextureButton


func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Maps/tutorial.tscn") # átváltja a jelenetet testplacere gomb megnyomásakor, kitörli a menu.tscn által foglalt memóriát 
