extends CharacterBody2D
@export var health = 25000
@export var maxhealth = 25000
@onready var HealthHud = $Health
@export var cantakedamage = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	HealthHud.visible = true
	HealthHud.get_node("Label").text = str(health) + "/" + str(maxhealth)
