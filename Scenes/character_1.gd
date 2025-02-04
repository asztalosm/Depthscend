class_name character1 extends CharacterBody2D
#itt ezek az exportok globális változók lesznek amiket el lehet érni más scriptekből
@export var speed = 250
@export var health = 70
@export var maxhealth = 70
@export var playerpos = Node2D
@export var accel = 35
var dir := Vector2.ZERO
#változó ami akkor jön létre amikor létrejön a karakter
@onready var navagent := $NavigationAgent2D as NavigationAgent2D 

var target = position

func _input(event):
	if event.is_action_pressed("click") and get_meta("active"):
		target = get_global_mouse_position()
		makepath()
	if event.is_action_pressed("Number 1 Character Selection") and get_meta("active"):
		health -= 5 # ez csak teszt jelleggel van itt. ez alapján fogom a dead cuccot megcsinálni


func makepath() -> void:
	navagent.target_position = target
	


func _on_timer_timeout() -> void:
		makepath()


func _physics_process(_delta: float) -> void:
	dir = navagent.get_next_path_position() - global_position
	if dir.length_squared() > 1.0:
		dir = dir.normalized()
	velocity = velocity.lerp(dir * speed, accel * _delta)
	move_and_slide()
