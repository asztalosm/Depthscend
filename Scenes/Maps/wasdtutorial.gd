extends Control
var inputlist = ["kb_W", "kb_A", "kb_S", "kb_D"]

func _input(event: InputEvent) -> void:
	if inputlist.size() == 0:
		queue_free()
	else:
		for i in inputlist:
			if event.is_action_pressed(i) and get_parent().canwasdmove:
				get_node(i).modulate = Color(0.5, 0.8, 0.5)
				inputlist.erase(i)
				get_parent().canmousemove = true
