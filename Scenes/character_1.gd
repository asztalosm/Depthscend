class_name character1 extends CharacterBody2D
#itt ezek az exportok globális változók lesznek amiket el lehet érni más scriptekből
@export var speed = 300 
@export var health = 70
@export var maxhealth = 70
var target = position

func _input(event):
	if event.is_action_pressed("click") and get_meta("active"):
		target = get_global_mouse_position()
	if event.is_action_pressed("Number 1 Character Selection") and get_meta("active"):
		health -= 5
		
		
func _physics_process(_delta: float) -> void:
	velocity = position.direction_to(target) * speed
	if position.distance_to(target) > 10:
		move_and_slide()
