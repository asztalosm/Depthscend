extends Control
var pausedgame = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		if pausedgame == false:
			get_tree().paused = true
			pausedgame = true
			show()
		else:
			get_tree().paused = false
			pausedgame = false
			hide()
