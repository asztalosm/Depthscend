extends Area2D
var characterinarea = false
var character = null
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("kb_E") and characterinarea and character != null:
		character.hasgroundslamcharm = true
		get_parent().get_node("MouseClick").visible = true
		var newtexturerect = TextureRect.new()
		newtexturerect.texture = load("res://Textures/Groundslam.png")
		newtexturerect.custom_minimum_size = Vector2(64,64)
		get_parent().get_parent().get_parent().get_node("Characters/GUI/Charms/GridContainer").add_child(newtexturerect)
		
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.get_parent().name == "character1":
		character = area.get_parent()
		characterinarea = true
		$UseButton.visible = true


func _on_area_exited(_area: Area2D) -> void:
	characterinarea = false
	$UseButton.visible = false
