extends Area2D
var characterinzone = false
var charactersnode
var charmlist = [
	["res://Textures/Groundslam.png", "character1"],
	["ds"],
	["fsd"],
]
var open = false

func rollcharm() -> void:
	var charmnum = randi_range(0, len(charmlist)-1)
	print("charm: ", charmlist[charmnum])
	print(charactersnode)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("kb_E") and characterinzone and !open:
		rollcharm()
		open = true
		if $ChestTexture.texture == load("res://Textures/chest_front.png"):
			$ChestTexture.texture = load("res://Textures/chest_front_open.png")
		else:
			$ChestTexture.texture = load("res://Textures/chest_side_open.png")
		$UseButton.visible = false


func _on_area_entered(area: Area2D) -> void:
	if area.get_parent().get_parent().name == "Characters" and !area.get_parent().get_meta("isDead") and area.get_parent().get_meta("active") and !open:
		characterinzone = true
		$UseButton.visible = true
		charactersnode = area.get_parent().get_parent()


func _on_area_exited(area: Area2D) -> void:
	if area.get_parent().get_parent().name == "Characters" and !area.get_parent().get_meta("isDead") and area.get_parent().get_meta("active") and !open:
		characterinzone = false
		$UseButton.visible = false
