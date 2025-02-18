extends CharacterBody2D
@export var health = 10
@export var maxhealth = 10
@onready var HealthHud = $Health

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	HealthHud.visible = true
	HealthHud.get_node("Label").text = str(health) + "/" + str(maxhealth)
	if health <= 0:
		get_parent().get_node("Door").queue_free()
		queue_free()
