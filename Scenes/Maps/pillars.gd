extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for elements in get_parent().get_node("Flowers").get_children():
		elements.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
