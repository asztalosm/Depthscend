extends Area2D
@export var usablecharacter : CharacterBody2D
var usable = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("kb_E") and usable:
		for charm in usablecharacter.charms:
			usablecharacter.charms[charm] = false



func _on_area_entered(area: Area2D) -> void:
	if usable:
		if area.get_parent().name == get_parent().charmcharacter:
			print("azonos karakter")
