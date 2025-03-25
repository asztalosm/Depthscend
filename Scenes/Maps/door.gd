extends Node2D
var dooropenable = false
var character = null

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("kb_E") and character != null:
		$StaticBody2D.queue_free()
		$AnimatedSprite2D.play("default")


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent().has_meta("active"):
		if area.get_parent().get_meta("active") and get_parent().get_node("Enemies").get_child_count() == 0:
			dooropenable = true
			character = area.get_parent()
			$InteractKey.visible = true
