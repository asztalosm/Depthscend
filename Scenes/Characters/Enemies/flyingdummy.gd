extends CharacterBody2D
var cantakedamage = true
var health = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if health < 1:
		print(health)
		if len(get_parent().get_children()) == 1:
			get_parent().get_parent().get_parent().get_parent().get_node("Characters").giveaccesstochar1 = true
			get_parent().get_parent().get_node("Door").queue_free()
		queue_free()
