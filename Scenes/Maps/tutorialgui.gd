extends CanvasLayer
@onready var pausemenu = $PauseMenu

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
