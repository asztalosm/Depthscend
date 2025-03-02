extends CanvasLayer
@onready var hoverstats = $HoverStats

func _on_current_character_mouse_entered(path) -> void:
	hoverstats.visible = true
	hoverstats.position = $CurrentCharacter.position + Vector2(400, 0)

func _on_current_character_mouse_exited() -> void:
	hoverstats.visible = false
