extends Sprite2D
var squinkscript = "res://Scenes/Characters/Enemies/Scripts/Squink.gd"

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		squinkscript.outline()
