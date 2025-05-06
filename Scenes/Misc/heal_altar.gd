extends Area2D
var healamount = 5
var characterlist = []
@onready var orbtexture = $TextureRect
var oncooldown = false

func heal():
	$AbilityPickup.play()
	for characters in characterlist:
		if characters.health == characters.maxhealth:
			pass
		elif characters.health +5 > characters.maxhealth:
			characters.health = characters.maxhealth
			characters.get_node("effects").play("heal")
			var charactereffect = preload("res://Shaders/characterstatuseffects.tscn").instantiate()
			characters.get_parent().add_child(charactereffect)
			charactereffect.texture = preload("res://Particles/Heal.png")
			charactereffect.global_position = characters.global_position
			charactereffect.emitting = true
		else:
			characters.health += 5
			characters.get_node("effects").play("heal")
			var charactereffect = preload("res://Shaders/characterstatuseffects.tscn").instantiate()
			characters.get_parent().add_child(charactereffect)
			charactereffect.texture = preload("res://Particles/Heal.png")
			charactereffect.global_position = characters.global_position
			charactereffect.emitting = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("kb_E") and characterlist != [] and !oncooldown:
		var canheal = false
		for characters in characterlist:
			if characters.get_meta("active"):
				canheal = true
		if canheal:
			heal()
			oncooldown = true
			$TextureRect.modulate = Color(1,1,1,0)
			var texturetween = get_tree().create_tween()
			$Timer.start()
			texturetween.tween_property($TextureRect, "modulate", Color(1,1,1,1), $Timer.time_left)
			texturetween.play()

func _process(_delta: float) -> void:
	if len(characterlist) > 0:
		$UseButton.visible = true
	else:
		$UseButton.visible = false


func _on_area_entered(area: Area2D) -> void:
	if area.get_parent().get_parent().name == "Characters":
		characterlist.append(area.get_parent())


func _on_area_exited(area: Area2D) -> void:
	if area.get_parent() in characterlist:
		characterlist.erase(area.get_parent())


func _on_timer_timeout() -> void:
	oncooldown = false
