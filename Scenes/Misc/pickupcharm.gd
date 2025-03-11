extends Area2D
@export var usablecharacter : CharacterBody2D
var usable = false
var rightcharacterinzone = false
var oldcharm

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("kb_E") and rightcharacterinzone and usablecharacter.get_meta("active"):
		for charm in len(usablecharacter.charms):
			if usablecharacter.charms[charm][1]:
				print(usablecharacter.charms[charm][0])


func _on_area_entered(area: Area2D) -> void:
	if usable:
		if area.get_parent().name == get_parent().charmcharacter and usablecharacter.get_meta("active"):
			rightcharacterinzone = true
			$UseButton.visible = true
		else:
			$UseButton.visible = false


func _on_area_exited(area: Area2D) -> void:
	if usable:
		if area.get_parent().name == get_parent().charmcharacter:
			rightcharacterinzone = false
			$UseButton.visible = false


func _process(_delta: float) -> void:
	if usable and rightcharacterinzone and usablecharacter.get_meta("active"):
		$UseButton.visible = true
	else:
		$UseButton.visible = false
