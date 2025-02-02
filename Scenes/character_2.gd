class_name character2 extends CharacterBody2D
#itt ezek az exportok globális változók lesznek amiket el lehet érni más scriptekből
@export var speed = 300
@export var health = 100
@export var maxhealth = 100
var target = position

func _input(event):
	if event.is_action_pressed("click") and get_meta("active"):
		target = get_global_mouse_position()
		
func _physics_process(_delta: float) -> void:
	velocity = position.direction_to(target) * speed
	if position.distance_to(target) > 10:
		move_and_slide()
