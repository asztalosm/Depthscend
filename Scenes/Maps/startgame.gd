extends TextureButton

var config = ConfigFile.new()
var err = config.load("user://config.cfg")

func _ready() -> void:
	if err != OK:
		config.set_value("playerdata", "hasplayedtutorial", false)
		config.save("user://config.cfg")


func _on_pressed() -> void:
	if config.get_value("playerdata", "hasplayedtutorial") == "true":
		get_tree().change_scene_to_file("res://Scenes/Maps/testplace.tscn") # átváltja a jelenetet testplacere gomb megnyomásakor, kitörli a menu.tscn által foglalt memóriát 
	else:
		get_parent().get_node("TutorialPrompt").visible = true
		


func _on_texture_button_pressed() -> void:
	pass # Replace with function body.
