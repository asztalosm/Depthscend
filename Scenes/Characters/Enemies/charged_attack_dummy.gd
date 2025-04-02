extends CharacterBody2D
@export var health = 6
@export var maxhealth = 6
@onready var HealthHud = $Health

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	HealthHud.visible = true
	HealthHud.get_node("Label").text = str(health) + "/" + str(maxhealth)
	if health <= 0:
		get_parent().get_node("Door").queue_free()
		get_parent().get_node("ChargeMouse").queue_free()
		queue_free()

func _on_timer_timeout() -> void:
	health = 6
