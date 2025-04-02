extends Area2D
@export var usablecharacter : CharacterBody2D
var rightcharacterinzone = false
var currentcharm = ""
var oldcharm = null
var usable = false
var inarea = []
var firstpickup = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("kb_E") and rightcharacterinzone and usablecharacter.get_meta("active") and usable:
		var counter = 0
		for charm in usablecharacter.charms:
			if charm[1]:
				counter += 1
		if counter == 0 and currentcharm != null:
			firstpickup = true
		for charm in usablecharacter.charms:
			if charm[1]:
				charm[1] = false
				oldcharm = charm[0]
				$CharmTexture.texture = charm[2]
			elif charm[0] == currentcharm:
				charm[1] = true
		currentcharm = oldcharm
		$AbilityPickup.play()
		if firstpickup:
			firstpickup = false
			queue_free()
	elif event.is_action_pressed("kb_E") and usable and len(inarea) > 0:
		$CharacterBG.modulate.r = 1.8
		await get_tree().create_timer(0.2).timeout
		$CharacterBG.modulate.r = 1


func _on_area_entered(area: Area2D) -> void:
	if area.get_parent().get_parent().name == "Characters":
		inarea.append(area.get_parent())
	for characters in inarea:
		if characters == usablecharacter and usablecharacter.get_meta("active"):
			$CharacterBG/CharacterTexture/CheckmarkTexture.visible = true
			rightcharacterinzone = true
		else:
			rightcharacterinzone = false
			$CharacterBG/CharacterTexture/CheckmarkTexture.visible = false
		if len(inarea) > 0:
				$CharacterBG.visible = true

func _on_area_exited(area: Area2D) -> void:
	if area.get_parent().get_parent().name == "Characters":
		inarea.erase(area.get_parent())
	if area.get_parent() == usablecharacter:
		rightcharacterinzone = false
		$CharacterBG/CharacterTexture/CheckmarkTexture.visible = false
	if len(inarea) == 0:
		$CharacterBG.visible = false
