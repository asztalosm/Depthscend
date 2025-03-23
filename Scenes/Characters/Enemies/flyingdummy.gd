extends CharacterBody2D
var cantakedamage = true
var health = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if health < 1:
		if len(get_parent().get_children()) == 1:
			get_parent().get_parent().get_parent().get_parent().get_node("Characters").giveaccesstochar1 = true
			get_parent().get_parent().get_node("Door").queue_free()
			var appeartween = get_tree().create_tween()
			appeartween.set_ease(Tween.EASE_IN_OUT)
			appeartween.set_parallel(true)
			appeartween.tween_property(get_parent().get_parent().get_node("Bridge"), "modulate:a", 1, 2)
			appeartween.tween_property(get_parent().get_parent().get_node("Bridge"), "position", Vector2(0,0), 2)
		queue_free()
