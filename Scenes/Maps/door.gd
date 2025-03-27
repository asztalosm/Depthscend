extends Node2D
var dooropenable = false
var characters = []
var dooropened = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("kb_E") and characters != [] and !dooropened and get_parent().get_node("Enemies").get_child_count() == 0:
		for character in characters:
			if character.get_meta("active"):
				$StaticBody2D.queue_free()
				dooropened = true
				$AnimatedSprite2D.play("default")
				$TextureRect.queue_free()

func _process(delta: float) -> void:
	if get_node_or_null(get_path_to(get_parent().get_node("Enemies"))) != null:
		if get_parent().get_node("Enemies").get_child_count() == 0:
			$AnimatedSprite2D.modulate = Color(1,1,1)
			if get_node_or_null("TextureRect") and len(characters) > 0:
				$TextureRect.visible = true


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent().has_meta("active"):
		characters.append(area.get_parent())
		dooropenable = true

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.get_parent().has_meta("active"):
		if area.get_parent().get_meta("active") and get_parent().get_node("Enemies").get_child_count() == 0:
			characters.erase(area.get_parent())
			if len(characters) == 0:
				dooropenable = false
			$AnimatedSprite2D.modulate = Color(0.7,0.7,0.7)
			if get_node_or_null("TextureRect"):
				$TextureRect.visible = false
