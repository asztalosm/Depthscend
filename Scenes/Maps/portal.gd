extends Node2D
var charactersinzone = []
var inzone = false

func _input(event: InputEvent) -> void:
	if inzone and event.is_action_pressed("kb_E"):
		get_tree().change_scene_to_file("res://Scenes/Maps/tutorial_2.tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	inzone = false
	for character in charactersinzone:
		if character.get_meta("active"):
			inzone = true
	if inzone:
		$InteractButton.visible = true
	else:
		$InteractButton.visible = false
		
		
	


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent().get_parent().name == "Characters" and $PortalBg.visible:
		charactersinzone.append(area.get_parent())


func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.get_parent().get_parent().name == "Characters":
		charactersinzone.erase(area.get_parent())
